# Keycloak Integration Guide

## Overview

This guide explains how to integrate your applications with the Keycloak identity management system deployed on Azure Container Apps.

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend APIs  │    │   Keycloak      │
│   Applications  │◄──►│   Services      │◄──►│   Container App │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                                        │
                                              ┌─────────▼─────────┐
                                              │   PostgreSQL      │
                                              │   Database        │
                                              └───────────────────┘
                                                        │
                                              ┌─────────▼─────────┐
                                              │   Azure Key Vault │
                                              │   (All Secrets)   │
                                              └───────────────────┘
```

## Deployment Instructions

### 1. Deploy Development Environment

```bash
# Navigate to dev environment
cd dev

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=keycloak-dev.tfplan

# Apply deployment
terraform apply keycloak-dev.tfplan
```

### 2. Deploy Homologation Environment

```bash
# Navigate to homolog environment
cd ../homologacao

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -out=keycloak-hml.tfplan

# Apply deployment
terraform apply keycloak-hml.tfplan
```

## Post-Deployment Configuration

### 1. Access Keycloak Admin Console

```bash
# Get admin password from Key Vault
ADMIN_PASSWORD=$(az keyvault secret show \
  --name keycloak-admin-password \
  --vault-name <key-vault-name> \
  --query value -o tsv)

# Access admin console at the output URL
echo "Admin URL: https://<keycloak-fqdn>/admin"
echo "Username: admin"
echo "Password: $ADMIN_PASSWORD"
```

### 2. Create Realm for Your Application

```bash
# Create a new realm using Keycloak Admin REST API
curl -X POST "https://<keycloak-fqdn>/admin/realms" \
  -H "Authorization: Bearer <access-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "realm": "financial-system",
    "enabled": true,
    "displayName": "Financial System",
    "accessTokenLifespan": 3600,
    "refreshTokenMaxReuse": 0
  }'
```

### 3. Configure Clients for Each Service

#### Users API Client
```json
{
  "clientId": "users-api",
  "enabled": true,
  "protocol": "openid-connect",
  "publicClient": false,
  "serviceAccountsEnabled": true,
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": true,
  "redirectUris": ["https://users-api.yourdomain.com/*"],
  "webOrigins": ["https://users-api.yourdomain.com"]
}
```

#### Projects API Client
```json
{
  "clientId": "projects-api",
  "enabled": true,
  "protocol": "openid-connect",
  "publicClient": false,
  "serviceAccountsEnabled": true,
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": true,
  "redirectUris": ["https://projects-api.yourdomain.com/*"],
  "webOrigins": ["https://projects-api.yourdomain.com"]
}
```

#### Frontend Application Client
```json
{
  "clientId": "financial-frontend",
  "enabled": true,
  "protocol": "openid-connect",
  "publicClient": true,
  "standardFlowEnabled": true,
  "implicitFlowEnabled": false,
  "directAccessGrantsEnabled": false,
  "redirectUris": ["https://app.yourdomain.com/*"],
  "webOrigins": ["https://app.yourdomain.com"]
}
```

## Application Integration Examples

### React Frontend Integration

```javascript
// Install keycloak-js
npm install keycloak-js

// keycloak.js
import Keycloak from 'keycloak-js';

const keycloak = new Keycloak({
  url: 'https://<keycloak-fqdn>',
  realm: 'financial-system',
  clientId: 'financial-frontend'
});

export default keycloak;

// App.js
import { useEffect, useState } from 'react';
import keycloak from './keycloak';

function App() {
  const [authenticated, setAuthenticated] = useState(false);

  useEffect(() => {
    keycloak.init({ onLoad: 'login-required' })
      .then(authenticated => {
        setAuthenticated(authenticated);
      });
  }, []);

  if (!authenticated) {
    return <div>Loading...</div>;
  }

  return (
    <div>
      <h1>Welcome, {keycloak.tokenParsed.preferred_username}!</h1>
      <button onClick={() => keycloak.logout()}>Logout</button>
    </div>
  );
}
```

### .NET API Integration

```csharp
// Install Microsoft.AspNetCore.Authentication.JwtBearer
// Install Microsoft.AspNetCore.Authentication.OpenIdConnect

// Program.cs
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add Keycloak authentication
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://<keycloak-fqdn>/realms/financial-system";
        options.Audience = "users-api";
        options.RequireHttpsMetadata = true;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true
        };
    });

builder.Services.AddAuthorization();

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();

// Protected endpoint
app.MapGet("/api/users", [Authorize] () => 
{
    return Results.Ok(new { message = "This is a protected endpoint" });
});

app.Run();
```

### Node.js API Integration

```javascript
// Install express, passport, passport-jwt, jwks-rsa

const express = require('express');
const passport = require('passport');
const { Strategy: JwtStrategy, ExtractJwt } = require('passport-jwt');
const jwksClient = require('jwks-rsa');

const app = express();

// JWT Strategy configuration
const client = jwksClient({
  jwksUri: 'https://<keycloak-fqdn>/realms/financial-system/protocol/openid-connect/certs'
});

function getKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

passport.use(new JwtStrategy({
  jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
  secretOrKeyProvider: getKey,
  issuer: 'https://<keycloak-fqdn>/realms/financial-system',
  audience: 'projects-api'
}, (payload, done) => {
  return done(null, payload);
}));

app.use(passport.initialize());

// Protected route
app.get('/api/projects', 
  passport.authenticate('jwt', { session: false }),
  (req, res) => {
    res.json({ 
      message: 'This is a protected endpoint',
      user: req.user.preferred_username 
    });
  }
);

app.listen(3000);
```

## Key Vault Secret Management

### Retrieving Secrets Programmatically

#### .NET Application
```csharp
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

// Using Managed Identity
var client = new SecretClient(
    new Uri("https://<key-vault-name>.vault.azure.net/"),
    new DefaultAzureCredential()
);

// Get client secret for API communication
var apiSecret = await client.GetSecretAsync("financial-api-key");
Console.WriteLine($"API Key: {apiSecret.Value.Value}");
```

#### Node.js Application
```javascript
const { DefaultAzureCredential } = require('@azure/identity');
const { SecretClient } = require('@azure/keyvault-secrets');

const credential = new DefaultAzureCredential();
const client = new SecretClient(
  "https://<key-vault-name>.vault.azure.net/",
  credential
);

// Get database password
async function getDatabasePassword() {
  const secret = await client.getSecret("keycloak-db-password");
  return secret.value;
}
```

## Security Best Practices

### 1. Token Validation
- Always validate JWT tokens on the server side
- Check token expiration and issuer
- Verify audience matches your application

### 2. Role-Based Access Control
```javascript
// Check user roles in JWT token
function hasRole(token, requiredRole) {
  const roles = token.realm_access?.roles || [];
  return roles.includes(requiredRole);
}

// Middleware for role checking
function requireRole(role) {
  return (req, res, next) => {
    if (!hasRole(req.user, role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    next();
  };
}

// Usage
app.get('/api/admin/users', 
  passport.authenticate('jwt', { session: false }),
  requireRole('admin'),
  (req, res) => {
    // Admin-only endpoint
  }
);
```

### 3. CORS Configuration
```javascript
// Frontend origin whitelist
const allowedOrigins = [
  'https://app.yourdomain.com',
  'https://admin.yourdomain.com'
];

app.use(cors({
  origin: function (origin, callback) {
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));
```

## Monitoring and Logging

### Application Insights Integration

```csharp
// .NET application
builder.Services.AddApplicationInsightsTelemetry();

// Custom telemetry
app.Use(async (context, next) => {
    var telemetryClient = context.RequestServices.GetService<TelemetryClient>();
    
    telemetryClient?.TrackEvent("UserAuthenticated", new Dictionary<string, string>
    {
        ["UserId"] = context.User.Identity.Name,
        ["Timestamp"] = DateTime.UtcNow.ToString()
    });
    
    await next();
});
```

## Troubleshooting

### Common Issues

1. **Token validation fails**
   - Check issuer URL format
   - Verify JWKS endpoint accessibility
   - Confirm audience configuration

2. **CORS errors**
   - Add frontend domain to Keycloak client web origins
   - Configure API CORS settings

3. **Key Vault access denied**
   - Verify managed identity permissions
   - Check Key Vault access policies

### Useful Commands

```bash
# Test Keycloak connectivity
curl -I https://<keycloak-fqdn>/health

# Get realm configuration
curl "https://<keycloak-fqdn>/realms/financial-system"

# Test token endpoint
curl -X POST "https://<keycloak-fqdn>/realms/financial-system/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=client_credentials&client_id=<client-id>&client_secret=<client-secret>"
```

## Cost Optimization

### Development Environment
- Total monthly cost: ~R$ 150.00
- PostgreSQL Basic: R$ 45.00
- Container Apps: R$ 80.00
- Key Vault: R$ 15.00
- Log Analytics: R$ 10.00

### Homologation Environment
- Total monthly cost: ~R$ 300.00
- PostgreSQL General Purpose: R$ 180.00
- Container Apps: R$ 100.00
- Key Vault: R$ 15.00
- Log Analytics: R$ 5.00

## Support and Maintenance

1. **Regular Updates**
   - Monitor Keycloak security updates
   - Update container images quarterly
   - Review access logs monthly

2. **Backup Strategy**
   - PostgreSQL automated backups enabled
   - Key Vault soft delete protection
   - Export realm configurations

3. **Disaster Recovery**
   - Cross-region backup for production
   - Documented recovery procedures
   - Regular DR testing
