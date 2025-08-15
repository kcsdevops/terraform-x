# 📊 PLANTAS TÉCNICAS PARA DRAW.IO - AMBIENTES DEV/HOMOLOG

## 🎯 Objetivo
Documentação visual completa da infraestrutura com três perspectivas especializadas:
- 🌐 **Planta de Rede**: Infraestrutura de conectividade e isolamento
- 🏗️ **Arquitetura de Sistemas**: Aplicações, dados e serviços
- �� **Arquitetura de Segurança**: Controles e defesas por camada

---

## 📁 Arquivos Criados

### 1. 🌐 **Planta-de-Rede.drawio**
**Foco**: Infraestrutura de rede e conectividade

#### 📋 **Conteúdo**:
- **VNets isoladas** com ranges dedicados
- **Subnets** e gateways por ambiente
- **NSGs** e regras de firewall
- **Private Endpoints** e roteamento
- **Load Balancers** e Application Gateways
- **Detalhes técnicos**: CIDR, IPs, MTU, DNS

#### 🎨 **Visualização**:
`
Internet → Load Balancer → Application Gateways
    ↓
DEV (10.100.x.x) 🚫 ISOLADO 🚫 HOMOLOG (10.200.x.x)
    ↓                           ↓
VNet → Subnet → NSG         VNet → Subnet → NSG
    ↓                           ↓
Private Endpoints           Private Endpoints
`

---

### 2. 🏗️ **Arquitetura-de-Sistemas.drawio**
**Foco**: Aplicações, dados e serviços distribuídos

#### 📋 **Conteúdo**:
- **Camada de Apresentação**: Web Apps, CDN, API Management
- **Camada de Aplicação**: App Services, Azure Functions
- **Camada de Dados**: SQL Database, Storage Accounts
- **Camada de Cache**: Redis, Application Insights
- **Especificações técnicas**: SKUs, custos, capacidades

#### 🎨 **Visualização**:
`
🎨 PRESENTATION: Web Apps → CDN → API Management
    ↓
⚙️ APPLICATION: App Services → Functions
    ↓
🗄️ DATA: SQL Database → Storage → Cache
    ↓
📊 MONITORING: App Insights → Log Analytics
`

---

### 3. 🔒 **Arquitetura-de-Seguranca.drawio**
**Foco**: Defense in Depth e controles de segurança

#### 📋 **Conteúdo**:
- **Internet Security**: DDoS, WAF, SSL/TLS, Rate Limiting
- **Network Security**: NSGs, firewalls, isolamento
- **Identity & Access**: Azure AD, RBAC, Service Principal
- **Data Security**: TDE, encryption, backup
- **Compliance**: Políticas, threat model, maturidade

#### 🎨 **Visualização**:
`
🌍 INTERNET: DDoS → WAF → SSL → Rate Limit
    ↓
🌐 NETWORK: NSG Rules → Firewalls → Isolation
    ↓
🔐 IDENTITY: Azure AD → RBAC → Service Principal
    ↓
🗄️ DATA: Encryption → Backup → Monitoring
    ↓
📋 COMPLIANCE: Policies → Audit → Maturity
`

---

## 🚀 Como Usar no Draw.io

### **Passo a Passo**:
1. **Acesse**: https://app.diagrams.net/
2. **Importe**: File → Import from → Device
3. **Selecione** um dos arquivos:
   - Planta-de-Rede.drawio
   - Arquitetura-de-Sistemas.drawio 
   - Arquitetura-de-Seguranca.drawio
4. **Visualize** e **edite** conforme necessário

### **🎨 Cores e Legendas**:
- 🟢 **Verde**: Ambiente DEV (desenvolvimento)
- 🟡 **Amarelo**: Ambiente HOMOLOG (homologação)
- 🔴 **Vermelho**: Segurança e bloqueios
- 🔵 **Azul**: Rede e infraestrutura
- 🟣 **Roxo**: Identidade e autenticação

---

## 📊 Especificações Técnicas Detalhadas

### **🌐 Rede (Ranges e IPs)**
| Ambiente | VNet Range | Subnet Range | Gateway | NSG |
|----------|------------|--------------|---------|-----|
| **DEV** | 10.100.0.0/16 | 10.100.1.0/24 | 10.100.1.1 | dev-nsg-isolated |
| **HOMOLOG** | 10.200.0.0/16 | 10.200.1.0/24 | 10.200.1.1 | hml-nsg-isolated |

### **🏗️ Sistemas (SKUs e Custos)**
| Componente | DEV | HOMOLOG | Custo DEV | Custo HML |
|------------|-----|---------|-----------|-----------|
| **SQL Database** | Basic (5 DTU) | S0 (10 DTU) | ~/mês | ~/mês |
| **App Service** | F1 (Free) | B1 (Basic) | Grátis | ~/mês |
| **Storage** | Standard LRS | Standard LRS | ~/mês | ~/mês |
| **Functions** | Consumption | Premium EP1 | Pay-per-use | ~/mês |

### **🔒 Segurança (Controles e Compliance)**
| Camada | Controle | DEV | HOMOLOG |
|--------|----------|-----|---------|
| **Internet** | DDoS Protection | Basic | Basic |
| **Network** | NSG Rules | Restritivo | Restritivo + Test |
| **Identity** | MFA | Obrigatório | Obrigatório |
| **Data** | Encryption | TDE | TDE + Backup |

---

## 🎯 Benefícios da Documentação Visual

### **👥 Para Stakeholders**:
- ✅ **Compreensão visual** da arquitetura
- ✅ **Isolamento garantido** entre ambientes
- ✅ **Custos otimizados** claramente demonstrados
- ✅ **Segurança por camadas** visível

### **🔧 Para Desenvolvedores**:
- ✅ **Ranges de IP** e conectividade
- ✅ **Endpoints e serviços** disponíveis
- ✅ **Fluxo de dados** entre componentes
- ✅ **Restrições de segurança** aplicadas

### **🛡️ Para Segurança**:
- ✅ **Controles implementados** por camada
- ✅ **Matriz de risco** e mitigações
- ✅ **Compliance** e políticas
- ✅ **Monitoring** e auditoria

---

## 📈 Próximos Passos

1. **📥 Importar** os diagramas no draw.io
2. **🔍 Revisar** especificações técnicas
3. **✏️ Customizar** conforme necessidades
4. **📤 Compartilhar** com equipes
5. **🔄 Manter** atualizado com mudanças

---

## 💡 Dicas de Uso

### **📝 Edição**:
- **Clique duplo** para editar textos
- **Arraste** para mover componentes
- **Ctrl+C/V** para copiar elementos
- **Delete** para remover objetos

### **🎨 Personalização**:
- **Cores**: Clique direito → Format
- **Texto**: Toolbar de formatação
- **Conectores**: Use as ferramentas de linha
- **Layers**: Para organizar complexidade

### **📤 Exportação**:
- **PNG/JPEG**: Para apresentações
- **PDF**: Para documentação
- **SVG**: Para web
- **VSDX**: Para Visio

**🎯 Documentação visual completa para arquitetura de classe enterprise!** 🚀

