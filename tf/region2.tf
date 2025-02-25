resource "azurerm_virtual_network" "r2-vnet" {
  name                = "mtnguyen22-VNet-R2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "northeurope"
  address_space       = ["172.16.123.0/24"]
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "ireland-frontend" {
  name                 = "myAGSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.r2-vnet.name
  address_prefixes     = ["172.16.123.96/27"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_subnet" "ireland-backend" {
  name                 = "myBackendSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.r2-vnet.name
  address_prefixes     = ["172.16.123.128/27"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "azurerm_public_ip" "eu_pip" {
  name                = "EUAGPublicIPAddress"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "northeurope"
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_virtual_network.vnet]
}


resource "azurerm_application_gateway" "lb2" {
  name                = "LB2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "northeurope"

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.ireland-frontend.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.eu_pip.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
    priority                   = 1
  }
}

resource "azurerm_network_interface" "ireland-nic" {
  count               = 2
  name                = "eu-nic-${count.index + 1}"
  location            = "northeurope"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.ireland-backend.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "lb2-nic-assoc" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.ireland-nic[count.index].id
  ip_configuration_name   = "nic-ipconfig-${count.index + 1}"
  backend_address_pool_id = one(azurerm_application_gateway.lb2.backend_address_pool).id
}


resource "azurerm_linux_virtual_machine" "ireland-vm" {
  count                           = 2
  name                            = "Ireland-webServer${count.index + 1}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = "northeurope"
  size                            = "Standard_B1s"
  disable_password_authentication = false
  admin_username                  = "azureadmin"
  admin_password                  = "Password@!12345678"

  network_interface_ids = [
    azurerm_network_interface.ireland-nic[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  custom_data = filebase64("${path.module}/cloud-init.txt")
}
