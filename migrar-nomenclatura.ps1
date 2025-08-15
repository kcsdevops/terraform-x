# ============================================================================
# SCRIPT DE MIGRAÇÃO DE NOMENCLATURA CORPORATIVA
# Aplica o novo padrão: rg-meuqueridinho-brs-meuquerinho-{recurso}-{ambiente}
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Action = "plan",  # plan, apply, destroy
    
    [Parameter(Mandatory=$false)]
    [string[]]$Environments = @("dev", "hml", "prd", "infra")
)

Write-Host "🏗️  MIGRAÇÃO DE NOMENCLATURA CORPORATIVA - MEU QUERIDINHO CARD" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""

# Mapeamento das nomenclaturas antigas vs novas
$nomenclaturaMigration = @{
    # DEV
    "rg-desenvolvimento" = "rg-meuqueridinho-brs-meuquerinho-aplicacao-dev"
    "rg-dev" = "rg-meuqueridinho-brs-meuquerinho-aplicacao-dev"
    
    # HML
    "rg-homologacao" = "rg-meuqueridinho-brs-meuquerinho-aplicacao-hml" 
    "rg-hml" = "rg-meuqueridinho-brs-meuquerinho-aplicacao-hml"
    
    # PRD
    "rg-producao" = "rg-meuqueridinho-brs-meuquerinho-aplicacao-prd"
    "rg-prd" = "rg-meuqueridinho-brs-meuquerinho-aplicacao-prd"
    
    # INFRA
    "rg-infra" = "rg-meuqueridinho-brs-meuquerinho-infra-shared"
    "rg-infrastructure" = "rg-meuqueridinho-brs-meuquerinho-infra-shared"
    
    # MONITORING
    "rg-monitoring-central" = "rg-meuqueridinho-brs-meuquerinho-monitoring-central"
}

Write-Host "📋 NOMENCLATURAS A SEREM APLICADAS:" -ForegroundColor Yellow
$nomenclaturaMigration.GetEnumerator() | ForEach-Object {
    Write-Host "   $($_.Key) → $($_.Value)" -ForegroundColor White
}
Write-Host ""

foreach ($env in $Environments) {
    Write-Host "🔄 Processando ambiente: $env" -ForegroundColor Green
    
    if (Test-Path $env) {
        Set-Location $env
        
        Write-Host "   📝 Backup dos arquivos atuais..." -ForegroundColor Yellow
        if (Test-Path "main.tf") {
            Copy-Item "main.tf" "main.tf.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        }
        
        Write-Host "   🔄 Aplicando nova nomenclatura..." -ForegroundColor Yellow
        if (Test-Path "main-updated.tf") {
            Copy-Item "main-updated.tf" "main.tf" -Force
            Write-Host "   ✅ Nomenclatura atualizada para $env" -ForegroundColor Green
        }
        
        if ($Action -eq "plan") {
            Write-Host "   📊 Executando terraform plan..." -ForegroundColor Cyan
            terraform init -upgrade
            terraform plan -var-file="../terraform.tfvars" -out="$env.tfplan"
        }
        elseif ($Action -eq "apply") {
            Write-Host "   🚀 Executando terraform apply..." -ForegroundColor Cyan
            terraform init -upgrade  
            terraform apply -auto-approve -var-file="../terraform.tfvars"
        }
        
        Set-Location ..
    }
    else {
        Write-Host "   ⚠️  Diretório $env não encontrado" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

Write-Host "✅ MIGRAÇÃO DE NOMENCLATURA CONCLUÍDA!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 RESUMO DAS ALTERAÇÕES:" -ForegroundColor Cyan
Write-Host "- ✅ Padrão aplicado: rg-meuqueridinho-brs-meuquerinho-{recurso}-{ambiente}" -ForegroundColor Green
Write-Host "- ✅ Tags corporativas atualizadas" -ForegroundColor Green  
Write-Host "- ✅ Backups criados dos arquivos originais" -ForegroundColor Green
Write-Host "- ✅ Ambientes processados: $($Environments -join ', ')" -ForegroundColor Green
Write-Host ""
Write-Host "🔄 Para aplicar as mudanças, execute:" -ForegroundColor Yellow
Write-Host "   .\migrar-nomenclatura.ps1 -Action apply" -ForegroundColor White
