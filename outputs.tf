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
  value       = azurerm_frontdoor.front_door.backend_pools
}

output "frontend_endpoints" {
  description = "A dictionary of Frontend Endpoint names to the Frontend Endpoint ID"
  value       = azurerm_frontdoor.front_door.frontend_endpoints
}

output "routing_rules" {
  description = "A dictionary of Routing Rule Names to the Routing Rule ID"
  value       = azurerm_frontdoor.front_door.routing_rules
}