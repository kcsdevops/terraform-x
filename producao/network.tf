module "vnet" {
  source              = "../modules/vnet"
  vnet_name           = "prd-vnet"
  address_space       = ["10.30.0.0/16"]
  location            = "brazilsouth"
  resource_group_name = "prd-rg"
  tags = {
    environment = "producao"
  }
}

module "subnet" {
  source               = "../modules/subnet"
  subnet_name          = "prd-subnet"
  resource_group_name  = "prd-rg"
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = ["10.30.1.0/24"]
  nsg_name             = "prd-nsg"
  location             = "brazilsouth"
  service_endpoints    = []
  delegation           = []
  security_rules = [
    {
      name                       = "AllowPrdWeb"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "10.30.0.0/16"
      destination_address_prefix = "*"
    }
  ]
}
