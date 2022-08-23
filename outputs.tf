output "front_door_name" {
  value = azurerm_frontdoor.front_door.name
}

output "front_door_id" {
  value = azurerm_frontdoor.front_door.id
}

output "backend_pools" {
  value       = azurerm_frontdoor.front_door.backend_pools
  description = "A dictionary of backend pool names to backend pool ID"
}