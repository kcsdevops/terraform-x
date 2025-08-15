module "vnet" {
  source              = "../modules/vnet"
  vnet_name           = "dev-vnet"
  address_space       = ["10.10.0.0/16"]
  location            = "brazilsouth"
  resource_group_name = "dev-rg"
  dns_servers         = []
  tags = {
    environment = "dev"
  }
}

module "subnet" {
  source               = "../modules/subnet"
  subnet_name          = "dev-subnet"
  resource_group_name  = "dev-rg"
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = ["10.10.1.0/24"]
  nsg_name             = "dev-nsg"
  location             = "brazilsouth"
  service_endpoints    = []
  delegation           = []
  security_rules = [
    {
      name                       = "AllowDevSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "10.10.0.0/16"
      destination_address_prefix = "*"
    }
  ]
}
