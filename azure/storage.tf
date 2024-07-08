resource "random_string" "sa" {
  length  = 15
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_storage_account" "homepage-sa" {
  name                     = "wshome${random_string.sa.result}"
  resource_group_name      = azurerm_resource_group.homepage-rg.name
  location                 = azurerm_resource_group.homepage-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "homepage-sc" {
  name                  = "webcode"
  storage_account_name  = azurerm_storage_account.homepage-sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "homepage-files" {
  for_each               = fileset("${path.module}/webcode/homepage", "**/*")
  name                   = each.key
  storage_account_name   = azurerm_storage_account.homepage-sa.name
  storage_container_name = azurerm_storage_container.homepage-sc.name
  type                   = "Block"
  source                 = "${path.root}/webcode/homepage/${each.key}"
  content_md5            = filemd5("${path.root}/webcode/homepage/${each.key}")
}

data "azurerm_storage_account_sas" "token" {
  connection_string = azurerm_storage_account.homepage-sa.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = false
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "2880h")

  permissions {
    read    = true
    write   = false
    delete  = false
    list    = true
    add     = false
    create  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

resource "azurerm_storage_account" "talent-sa" {
  name                     = "wsassets${random_string.sa.result}"
  resource_group_name      = azurerm_resource_group.talent-rg.name
  location                 = azurerm_resource_group.talent-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "talent-sc" {
  name                  = "media"
  storage_account_name  = azurerm_storage_account.talent-sa.name
  container_access_type = "container"
}

resource "azurerm_storage_blob" "talent-files" {
  for_each               = fileset("${path.module}/webcode/talent/storage", "**/*")
  name                   = each.key
  storage_account_name   = azurerm_storage_account.talent-sa.name
  storage_container_name = azurerm_storage_container.talent-sc.name
  type                   = "Block"
  source                 = "${path.root}/webcode/talent/storage/${each.key}"
  content_md5            = filemd5("${path.root}/webcode/talent/storage/${each.key}")
}
