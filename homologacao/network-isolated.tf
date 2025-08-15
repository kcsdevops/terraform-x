# Configuração de Rede ISOLADA para HOMOLOGAÇÃO
# Segmentação completa com regras de segurança específicas

module "vnet" {
  source              = "../modules/vnet"
  vnet_name           = "hml-vnet-isolated"
  address_space       = ["10.200.0.0/16"]  # Range específico para HOMOLOG
  location            = "brazilsouth"
  resource_group_name = "hml-rg-min"
  dns_servers         = []
  tags = {
    environment = "homolog"
    network_tier = "isolated"
    cost_tier = "minimal"
    testing = "pre-prod"
  }
}

module "subnet" {
  source               = "../modules/subnet"
  subnet_name          = "hml-subnet-isolated"
  resource_group_name  = "hml-rg-min"
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = ["10.200.1.0/24"]  # Subnet específica HOMOLOG
  nsg_name             = "hml-nsg-isolated"
  location             = "brazilsouth"
  service_endpoints    = []
  delegation           = []
  security_rules = [
    {
      name                       = "AllowHmlHTTPS"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "10.200.0.0/16"  # Só tráfego interno HOMOLOG
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHmlSQL"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "10.200.1.0/24"  # Só da subnet HOMOLOG
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowHmlTesting"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8080"
      source_address_prefix      = "10.200.0.0/16"  # Porta para testes
      destination_address_prefix = "*"
    },
    {
      name                       = "DenyAllOtherEnvironments"
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "10.0.0.0/8"     # Nega outros ranges 10.x
      destination_address_prefix = "*"
    }
  ]
}
