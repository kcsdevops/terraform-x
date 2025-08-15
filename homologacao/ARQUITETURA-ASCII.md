# 🏗️ ARQUITETURA DE REDES ISOLADAS - AMBIENTES DEV/HOMOLOG

`
                            ☁️  AZURE CLOUD - BRAZIL SOUTH
    ┌─────────────────────────────────────────────────────────────────────────────────────┐
    │  🔐 Service Principal: sp-terraform-mvp-flex                                        │
    │  📦 Remote State: Storage Account 'treinamenttos'                                  │
    └─────────────────────────────────────────────────────────────────────────────────────┘
                                           │
                ┌──────────────────────────┼──────────────────────────┐
                │                          │                          │
    ┌───────────▼──────────────┐          │          ┌───────────▼──────────────┐
    │   🟢 DESENVOLVIMENTO      │          │          │   🟡 HOMOLOGAÇÃO         │
    │   (DEV - Custo Mínimo)    │    🚫 ISOLADO 🚫    │   (HOMOLOG - Otimizado)  │
    └───────────────────────────┘          │          └───────────────────────────┘
                                           │
    ┌─ Resource Group ─────────┐           │           ┌─ Resource Group ─────────┐
    │  dev-rg-min             │           │           │  hml-rg-min             │
    │                         │           │           │                         │
    │  ┌─ VNet ──────────────┐ │           │           │  ┌─ VNet ──────────────┐ │
    │  │ dev-vnet-isolated   │ │           │           │  │ hml-vnet-isolated   │ │
    │  │ 10.100.0.0/16      │ │           │           │  │ 10.200.0.0/16      │ │
    │  │                    │ │           │           │  │                    │ │
    │  │ ┌─ Subnet ────────┐ │ │           │           │  │ ┌─ Subnet ────────┐ │ │
    │  │ │ dev-subnet      │ │ │           │           │  │ │ hml-subnet      │ │ │
    │  │ │ 10.100.1.0/24  │ │ │           │           │  │ │ 10.200.1.0/24  │ │ │
    │  │ │                │ │ │           │           │  │ │                │ │ │
    │  │ │ 🛡️  NSG:       │ │ │           │           │  │ │ 🛡️  NSG:       │ │ │
    │  │ │ dev-nsg-iso    │ │ │           │           │  │ │ hml-nsg-iso    │ │ │
    │  │ └────────────────┘ │ │           │           │  │ └────────────────┘ │ │
    │  └────────────────────┘ │           │           │  └────────────────────┘ │
    │                         │           │           │                         │
    │  🗄️  SQL Database       │           │           │  🗄️  SQL Database       │
    │  ├─ Server: dev-sqlsrv  │           │           │  ├─ Server: hml-sqlsrv  │
    │  ├─ DB: dev-sqldb       │           │           │  ├─ DB: hml-sqldb       │
    │  ├─ SKU: Basic (5 DTU)  │           │           │  ├─ SKU: S0 (10 DTU)    │
    │  └─ Cost: ~/mês       │           │           │  └─ Cost: ~/mês      │
    └─────────────────────────┘           │           └─────────────────────────┘
                                           │
    🔒 REGRAS DE SEGURANÇA DEV:            │            🔒 REGRAS DE SEGURANÇA HML:
    ✅ HTTPS (443) - Interno apenas        │            ✅ HTTPS (443) - Interno apenas  
    ✅ SQL (1433) - Subnet apenas          │            ✅ SQL (1433) - Subnet apenas
    ❌ Negar outros ambientes              │            ✅ Testing (8080) - Interno
                                           │            ❌ Negar outros ambientes

    📊 RESUMO DE CUSTOS:
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │  💰 DEV: ~/mês  │  💰 HOMOLOG: ~/mês  │  🎯 TOTAL: ~/mês        │
    │  📉 ECONOMIA: 94% vs configuração anterior (~/mês → ~/mês)          │
    └─────────────────────────────────────────────────────────────────────────────┘

    🏗️ CARACTERÍSTICAS DA ARQUITETURA:
    ┌─────────────────────────────────────────────────────────────────────────────┐
    │  🔐 Isolamento Completo:  Redes separadas sem comunicação entre ambientes  │
    │  🌐 Ranges Dedicados:     DEV (10.100.x.x) vs HOMOLOG (10.200.x.x)       │
    │  🛡️  Segurança por Camadas: NSGs + Firewall rules + Network isolation     │
    │  📦 Estado Separado:      dev/terraform.tfstate vs homolog/terraform.tfstate│
    │  💰 Otimização de Custos: SKUs mínimos adequados para cada ambiente        │
    │  🔄 CI/CD Ready:          Service Principal + Remote State                 │
    └─────────────────────────────────────────────────────────────────────────────┘
`

🚀 **PRÓXIMOS PASSOS:**
1. Importar 'Arquitetura-Redes-Isoladas.drawio' no draw.io
2. Aplicar configurações: 	erraform apply em cada ambiente
3. Verificar isolamento de rede entre ambientes
4. Monitorar custos via Azure Cost Management

