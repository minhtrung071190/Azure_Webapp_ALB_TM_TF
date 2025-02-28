variable "rg_name" {
  default = "myRG"
}

variable "vnet_r1_name" {
  default = "myVnet1Name"
}

variable "vnet_r2_name" {
  default = "myVnet2Name"
}

variable "var.traffic_manager_name" {
  default = "myTrafficManagerName"
}

variable "backend_address_pool_name" {
  default = "myBackendPool"
}

variable "frontend_port_name" {
  default = "myFrontendPort"
}

variable "frontend_ip_configuration_name" {
  default = "myAGIPConfig"
}

variable "http_setting_name" {
  default = "myHTTPsetting"
}

variable "listener_name" {
  default = "myListener"
}

variable "request_routing_rule_name" {
  default = "myRoutingRule"
}
