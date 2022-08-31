# Copyright 2022 Nexient LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

  frontend_endpoints_map = { for ep in azurerm_frontdoor.front_door.frontend_endpoint : ep.name => ep.id }

  create_cname_for_endpoints = { for key, ep in var.frontend_endpoints: key => ep if ep.create_record && lower(ep.record_type) == "cname" }
}