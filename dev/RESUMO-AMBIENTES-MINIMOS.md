# RESUMO: Ambientes Reconfigurados com Recursos Mínimos

## Objetivo
Recriar ambientes de **DEV** e **HOMOLOG** com menor custo possível mantendo funcionalidade.

## Comparação de Custos (aproximado mensal em USD)

### DESENVOLVIMENTO (DEV)
| Recurso | Antes (5k users) | Depois (Mínimo) | Economia |
|---------|------------------|-----------------|----------|
| **SQL Database** | GP_S_Gen5_2 (~) | Basic (~) | ~ |
| **VNet/Subnet** | Padrão (~) | Mínimo (~) | ~ |
| **Storage** | Standard LRS (~) | Standard LRS (~) | ~ |
| **NSG** | Padrão (~) | Mínimo (~) | ~ |
| **Total Estimado** | **~/mês** | **~/mês** | **~/mês** |

### HOMOLOGAÇÃO (HOMOLOG)
| Recurso | SKU | Custo Estimado |
|---------|-----|----------------|
| **SQL Database** | S0 (10 DTU) | ~/mês |
| **VNet/Subnet** | Mínimo | ~/mês |
| **Storage** | Standard LRS | ~/mês |
| **NSG** | Mínimo | ~/mês |
| **Total Estimado** | | **~/mês** |

## Arquitetura Implementada

### **DEV - Recursos Mínimos**
`
Resource Group: dev-rg-min
├── SQL Server: dev-sqlsrv-min
│   └── Database: dev-sqldb-min (Basic - 5 DTU, 2GB)
├── VNet: dev-vnet-min (10.10.0.0/16)
│   └── Subnet: dev-subnet-min (10.10.1.0/24)
└── NSG: dev-nsg-min
`

### **HOMOLOG - Recursos Otimizados**  
`
Resource Group: hml-rg-min
├── SQL Server: hml-sqlsrv-min
│   └── Database: hml-sqldb-min (S0 - 10 DTU, 250GB)
├── VNet: hml-vnet-min (10.20.0.0/16)
│   └── Subnet: hml-subnet-min (10.20.1.0/24)
└── NSG: hml-nsg-min
`

## SKUs Selecionados para Otimização

### **�SQL Database**
- **DEV**: Basic (5 DTU, 2GB) - Ideal para desenvolvimento e testes básicos
- **HOMOLOG**: S0 (10 DTU, 250GB) - Adequado para testes de integração

### **Networking**
- **Separação de Redes**: DEV (10.10.x.x) vs HOMOLOG (10.20.x.x)
- **Subnets Mínimas**: /24 (254 IPs cada)
- **NSGs Básicos**: Regras essenciais de segurança

### **� Storage**
- **Tier**: Standard (mais econômico que Premium)
- **Replicação**: LRS (Local Redundant Storage)
- **Access Tier**: Hot (padrão para desenvolvimento)

## Configurações de Segurança Mantidas

**TLS 1.2** mínimo para SQL Server
**Transparent Data Encryption** habilitado
**Network Security Groups** com regras básicas
**Tags de controle de custos** implementadas
**Backend remoto** separado por ambiente

## Comandos para Deploy

### DEV:
`ash
cd dev
terraform plan
terraform apply -auto-approve
`

### HOMOLOG:
`ash
cd ../homologacao  
terraform plan
terraform apply -auto-approve
`

## � Economia Total Estimada
- **Antes**: ~/mês (só DEV)
- **Depois**: ~/mês (DEV + HOMOLOG)
- **ECONOMIA: ~/mês (~94% de redução)**

## Limitações dos Recursos Mínimos

### **DEV (Basic)**
- Sem backup automático de 7 dias
- Limitado a 2GB de dados
- Performance básica (5 DTU)
- Ideal para desenvolvimento simples

### **HOMOLOG (S0)**  
- Backup automático de 7 dias
- Até 250GB de dados
- Performance adequada (10 DTU)
- Ideal para testes de integração

## Próximos Passos
1. **Deploy dos ambientes** com 	erraform apply
2. **Monitoramento de custos** via Azure Cost Management
3. **Auto-shutdown** configurado via tags
4. **Scale up** conforme necessário para produção
