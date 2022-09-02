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

output "front_door_name" {
  description = "Name of the Front Door instance"
  value       = azurerm_frontdoor.front_door.name
}

output "front_door_id" {
  description = "ID of the Front Door instance"
  value       = azurerm_frontdoor.front_door.id
}

output "backend_pools" {
  description = "A dictionary of backend pool names to backend pool ID"
  value       = { for backend in azurerm_frontdoor.front_door.backend_pool : backend.name => backend.id }
}

output "frontend_endpoints" {
  description = "A dictionary of Frontend Endpoint names to the Frontend Endpoint ID"
  value       = local.frontend_endpoints_map
}

output "routing_rules" {
  description = "A dictionary of Routing Rule IDs to enabled flag"
  value       = { for rule in azurerm_frontdoor.front_door.routing_rule : rule.id => rule.enabled }
}
