locals {
  default_tags = {
    provisioner = "Terraform"
  }

  tags = merge(local.default_tags, var.custom_tags)

  default_frontend_endpoint = {
    name      = replace(var.front_door_name, "-fd-", "-fdep-")
    host_name = "${var.front_door_name}.azurefd.net"
  }


  default_routing_rule = {
    name                     = var.routing_rule_name
    frontend_endpoint_names  = toset(concat([local.default_frontend_endpoint.name], var.frontend_endpoint_names))
    accepted_protocols       = var.accepted_protocols
    patterns_to_match        = var.patterns_to_match
    enabled                  = var.routing_rule_enabled
    forwarding_configuration = var.forwarding_configurations
    redirect_configuration   = var.redirect_configurations
  }

  routing_rules = merge({
    default-routing-rule = local.default_routing_rule
  }, var.additional_routing_rules)
}