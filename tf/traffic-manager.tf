resource "random_string" "azurerm_traffic_manager_profile_name" {
  length  = 25
  upper   = false
  numeric = false
  special = false
}


resource "azurerm_traffic_manager_profile" "profile" {
  name                   = "mtnguyen22"
  resource_group_name    = azurerm_resource_group.rg.name
  traffic_routing_method = "Performance"
  dns_config {
    relative_name = "mtnguyen22"
    ttl           = 30
  }

  monitor_config {
    protocol                    = "HTTP"
    port                        = 80
    path                        = "/"
    expected_status_code_ranges = ["200-202", "301-302"]
  }
}

resource "azurerm_traffic_manager_external_endpoint" "endpoint1" {
  profile_id        = azurerm_traffic_manager_profile.profile.id
  name              = "canadacentral"
  target            = azurerm_public_ip.ca_pip.ip_address
  endpoint_location = "canadacentral"
  weight            = 50
  depends_on        = [azurerm_public_ip.ca_pip]
}

resource "azurerm_traffic_manager_external_endpoint" "endpoint2" {
  profile_id        = azurerm_traffic_manager_profile.profile.id
  name              = "westeurope"
  target            = azurerm_public_ip.eu_pip.ip_address
  endpoint_location = "westeurope"
  weight            = 50
  depends_on        = [azurerm_public_ip.eu_pip]
}