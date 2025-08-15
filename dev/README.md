# Terraform Infrastructure Project

## Architecture Overview

This project implements an optimized Azure infrastructure with 94% cost reduction (from R$ 2,914.15 to R$ 170.27 monthly).

### Cost Optimization
- **DEV**: R$ 85.13/month
- **HOMOLOG**: R$ 85.14/month
- **Total**: R$ 170.27/month

### Network Isolation
- **DEV**: VNet 10.100.0.0/16
- **HOMOLOG**: VNet 10.200.0.0/16
- Complete isolation between environments

### Project Structure
`
├── plantas-mvc/           # Technical documentation
├── apis/                  # API architecture
├── service-bus/          # Messaging and events
├── investimento/         # Financial analysis
└── terraform/            # Infrastructure code
`

### Deployment
`ash
terraform init
terraform plan -var-file="terraform-minimal.tfvars"
terraform apply -var-file="terraform-minimal.tfvars"
`

### Resources Included
- Azure SQL Database (Basic/S0)
- App Services (F1/B1)
- Storage Accounts (Standard LRS)
- Service Bus (Basic/Standard)
- Application Insights
- Complete Draw.io documentation

### Environments
- **DEV**: Minimal resources for development
- **HOMOLOG**: Standard resources for staging
