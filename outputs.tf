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