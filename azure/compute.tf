resource "random_string" "password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "homepage" {
  name                        = "ws-homepage-vmss"
  resource_group_name         = azurerm_resource_group.homepage-rg.name
  location                    = azurerm_resource_group.homepage-rg.location
  platform_fault_domain_count = 1
  instances                   = 2
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  sku_name = var.vm_size
  network_interface {
    name = "homepage-nic"
    ip_configuration {
      name      = "homepage-ipconfig"
      subnet_id = azurerm_subnet.homepage-subnet.id
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.homepage-bap.id
      ]
    }
  }
  os_profile {
    linux_configuration {
      disable_password_authentication = false
      admin_username                  = "student"
      admin_password                  = random_string.password.result
      computer_name_prefix            = "homepage"
    }
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }
  user_data_base64 = base64encode(templatefile("${path.module}/userdata/homepage.sh.tftpl", {
    sas_token       = data.azurerm_storage_account_sas.token.sas,
    storage_account = azurerm_storage_account.homepage-sa.name,
    container_name  = azurerm_storage_container.homepage-sc.name
  }))
}

resource "azurerm_mysql_flexible_server" "talentdb-server" {
  name                   = "talentdb-${random_string.sa.result}"
  resource_group_name    = azurerm_resource_group.talent-rg.name
  location               = azurerm_resource_group.talent-rg.location
  administrator_login    = "student"
  administrator_password = random_string.password.result
  sku_name               = "GP_Standard_D2ds_v4"
  zone                   = 1
}

resource "azurerm_mysql_flexible_database" "talentdb-db" {
  name                = "talentdb"
  resource_group_name = azurerm_resource_group.talent-rg.name
  server_name         = azurerm_mysql_flexible_server.talentdb-server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_service_plan" "talentasp" {
  name                = "talent-${random_string.sa.result}"
  location            = azurerm_resource_group.talent-rg.location
  resource_group_name = azurerm_resource_group.talent-rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

data "archive_file" "talentwa" {
  type        = "zip"
  source_dir  = "${path.module}/webcode/talent/server"
  output_path = "${path.module}/webcode/talent.zip"
}

resource "azurerm_linux_web_app" "talentwa" {
  name                = "talent-${random_string.sa.result}"
  location            = azurerm_resource_group.talent-rg.location
  resource_group_name = azurerm_resource_group.talent-rg.name
  service_plan_id     = azurerm_service_plan.talentasp.id
  https_only          = true
  app_settings = {
    "DB_HOST"     = azurerm_mysql_flexible_server.talentdb-server.fqdn
    "DB_NAME"     = azurerm_mysql_flexible_database.talentdb-db.name
    "DB_USER"     = azurerm_mysql_flexible_server.talentdb-server.administrator_login
    "DB_PASS"     = azurerm_mysql_flexible_server.talentdb-server.administrator_password
    "SA_URL"      = azurerm_storage_account.talent-sa.primary_blob_endpoint
    "PORT"        = "8888"
  }
  site_config {
    minimum_tls_version = "1.2"
    application_stack {
      node_version = "20-lts"
    }
  }
  zip_deploy_file = data.archive_file.talentwa.output_path
}

# resource "azurerm_app_service_source_control" "sourcecontrol" {
#   app_id                 = azurerm_linux_web_app.talentwa.id
#   repo_url               = "https://github.com/ryananicholson/which-reality"
#   branch                 = "i01"
#   use_manual_integration = true
# }
