// CosmosDB for MongoDB API
resource "azurerm_cosmosdb_account" "mongo" {
  name                = "${var.resource_group_name}-mongo"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "MongoDB"
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
  capabilities {
    name = "EnableMongo"
  }
}

resource "azurerm_cosmosdb_mongo_database" "db" {
  name                = "financeirodb"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.mongo.name
}
