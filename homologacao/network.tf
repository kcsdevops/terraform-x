module "vnet" {
  source              = "../modules/vnet"
  vnet_name           = "hml-vnet"
  address_space       = ["10.20.0.0/16"]
  location            = "brazilsouth"
  resource_group_name = "hml-rg"
  dns_servers         = []
  tags = {
    environment = "homologacao"
  }
}

module "subnet" {
  source               = "../modules/subnet"
  subnet_name          = "hml-subnet"
  resource_group_name  = "hml-rg"
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = ["10.20.1.0/24"]
  nsg_name             = "hml-nsg"
  location             = "brazilsouth"
  delegation           = []
  service_endpoints    = []
  security_rules = [
    {
      name                       = "AllowHmlWeb"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "10.20.0.0/16"
      destination_address_prefix = "*"
    }
  ]
}
