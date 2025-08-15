# Projeto Financeiro – Infraestrutura Azure com Terraform

## Visão Geral
Este projeto provê uma infraestrutura completa e segura para um sistema de cartões de benefícios, rodando em containers .NET 8 no Azure, com separação de ambientes (dev, homologação, produção), integração de rede, segurança máxima e automação via Terraform.

## Estrutura dos Módulos
- **modules/appservice**: App Service Plan e Web Apps (container, VNet integration)
- **modules/sql**: Azure SQL Server e Database
- **modules/storage**: Storage Account, Blob e Queue
- **modules/acr**: Azure Container Registry (ACR)
- **modules/vnet**: Virtual Network
- **modules/subnet**: Subnet e Network Security Group (NSG)
- **modules/private_endpoint**: Private Endpoint para recursos sensíveis (ex: ACR)
- **modules/tags**: Padrão de tags corporativo

## Padrão de Ambientes
- `dev/`, `homologacao/`, `producao/`: Cada pasta contém um main.tf e network.tf, instanciando os módulos com parâmetros específicos do ambiente.

## Segurança
- Todos os recursos críticos podem ser integrados à VNet e subnets privadas.
- NSG aplicado a todas as subnets.
- Private Endpoint disponível para ACR e pode ser replicado para SQL, Storage, etc.
- Tags e nomes padronizados para governança.

## Deploy de Aplicação
- Web Apps rodam containers .NET 8 publicados no ACR.
- Exemplo de pipeline CI/CD (GitHub Actions) incluso para build/push da imagem Docker.

## Como Usar
1. Ajuste variáveis e parâmetros nos arquivos de ambiente conforme sua necessidade.
2. Execute `terraform init` e `terraform apply` no diretório do ambiente desejado.
3. Publique sua imagem .NET 8 no ACR usando o pipeline sugerido.
4. O App Service buscará a imagem do ACR e rodará em ambiente seguro.

## Exemplos de Integração
Veja os arquivos `main.tf` e `network.tf` de cada ambiente para exemplos práticos de uso dos módulos.

## Recomendações
- Use Managed Identity para acesso seguro ao ACR.
- Habilite Private Endpoints para todos os recursos sensíveis.
- Configure alertas e monitoramento via Application Insights.
- Mantenha o padrão de tags para facilitar auditoria e governança.

---

> Dúvidas ou sugestões? Consulte os módulos ou abra uma issue.
