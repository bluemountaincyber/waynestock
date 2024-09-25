resource "azurerm_virtual_network" "homepage-vnet" {
  name                = "ws-Homepage-VNET"
  resource_group_name = azurerm_resource_group.homepage-rg.name
  location            = azurerm_resource_group.homepage-rg.location
  address_space = [
    "10.0.0.0/16"
  ]
}
resource "azurerm_subnet" "homepage-subnet" {
  name                 = "ws-Homepage-Subnet"
  resource_group_name  = azurerm_resource_group.homepage-rg.name
  virtual_network_name = azurerm_virtual_network.homepage-vnet.name
  address_prefixes = [
    "10.0.0.0/24"
  ]
}

resource "azurerm_network_security_group" "homepage-nsg" {
  name                = "ws-Homepage-NSG"
  resource_group_name = azurerm_resource_group.homepage-rg.name
  location            = azurerm_resource_group.homepage-rg.location
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsga" {
  subnet_id                 = azurerm_subnet.homepage-subnet.id
  network_security_group_id = azurerm_network_security_group.homepage-nsg.id
}

resource "azurerm_public_ip" "homepage-pip" {
  name                = "ws-Homepage-PIP"
  resource_group_name = azurerm_resource_group.homepage-rg.name
  location            = azurerm_resource_group.homepage-rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "homepage-lb" {
  name                = "ws-Homepage-LB"
  resource_group_name = azurerm_resource_group.homepage-rg.name
  location            = azurerm_resource_group.homepage-rg.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.homepage-pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "homepage-bap" {
  name            = "ws-Homepage-BAP"
  loadbalancer_id = azurerm_lb.homepage-lb.id
}

resource "azurerm_lb_probe" "http-probe" {
  loadbalancer_id = azurerm_lb.homepage-lb.id
  name            = "http-running-probe"
  port            = 80
}

resource "azurerm_lb_rule" "homepage-lbr" {
  loadbalancer_id                = azurerm_lb.homepage-lb.id
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.homepage-bap.id]
  probe_id                       = azurerm_lb_probe.http-probe.id
}

resource "azurerm_cdn_frontdoor_profile" "fdp" {
  name                     = "wsfd"
  resource_group_name      = azurerm_resource_group.homepage-rg.name
  sku_name                 = "Premium_AzureFrontDoor"
  response_timeout_seconds = 30
}

resource "azurerm_cdn_frontdoor_rule_set" "fdrs" {
  name                     = "wsfdrs"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
}

resource "azurerm_cdn_frontdoor_endpoint" "fde" {
  name                     = "ws"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
}

resource "azurerm_cdn_frontdoor_origin_group" "fdog" {
  name                     = "ws-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fdp.id
  session_affinity_enabled = true

  restore_traffic_time_to_healed_or_new_endpoint_in_minutes = 5

  health_probe {
    interval_in_seconds = 5
    path                = "/health.html"
    protocol            = "Http"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 4
    successful_samples_required        = 3
  }
}

resource "azurerm_cdn_frontdoor_origin" "fdo" {
  name                          = "homepage"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdog.id
  enabled                       = true

  certificate_name_check_enabled = false

  host_name  = azurerm_public_ip.homepage-pip.ip_address
  http_port  = 80
  https_port = 443
  priority   = 1
  weight     = 1
}

resource "azurerm_cdn_frontdoor_route" "fdr" {
  name                          = "homepage-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fde.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fdog.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fdo.id]
  cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.fdrs.id]
  enabled                       = true

  forwarding_protocol    = "HttpOnly"
  https_redirect_enabled = false
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  link_to_default_domain = true
}

resource "azurerm_mysql_flexible_server_firewall_rule" "talentdb-fwr" {
  name                = "all-in"
  resource_group_name = azurerm_resource_group.talent-rg.name
  server_name         = azurerm_mysql_flexible_server.talentdb-server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
