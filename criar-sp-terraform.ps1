# Variáveis - ajuste conforme necessário
$resourceGroupName = "mvp-flex"
$spName = "stst-terraform"

# Obtenha o ID da subscription atual
$subscriptionId = (Get-AzContext).Subscription.Id

# Crie o Service Principal com permissão de Contributor apenas no Resource Group
$sp = New-AzADServicePrincipal -DisplayName $spName
New-AzRoleAssignment -ObjectId $sp.Id -RoleDefinitionName "Contributor" -ResourceGroupName $resourceGroupName

# Exiba as credenciais
$app = Get-AzADApplication -DisplayName $spName
$tenantId = (Get-AzContext).Tenant.Id

Write-Host "AppId: $($sp.AppId)"
Write-Host "TenantId: $tenantId"
Write-Host "SubscriptionId: $subscriptionId"
Write-Host "ResourceGroup: $resourceGroupName"

.\criar-sp-terraform.ps1
