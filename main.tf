resource "azurerm_frontdoor" "front_door" {
  name = var.front_door_name
  resource_group_name = var.resource_group.name

  dynamic "backend_pool" {
    for_each = var.backend_pools
    content {
      name = backend_pool.key
      load_balancing_name = backend_pool.value.load_balancing.name
      health_probe_name = backend_pool.value.health_probe.name

      dynamic "backend" {
        for_each = backend_pool.value.backends
        content {
          enabled = backend.value.enabled
          address = backend.value.address
          host_header = backend.value.host_header
          http_port = backend.value.http_port
          https_port = backend.value.https_port
          priority = backend.value.priority
          weight = backend.value.weight
        }
      }
    }
  }

  dynamic "backend_pool_health_probe" {
    for_each = var.backend_pools
    content {
      enabled = backend_pool_health_probe.value.health_probe.enabled
      name = backend_pool_health_probe.value.health_probe.name
      path = backend_pool_health_probe.value.health_probe.path
      protocol = backend_pool_health_probe.value.health_probe.protocol
      probe_method = backend_pool_health_probe.value.health_probe.probe_method
    }
  }

  dynamic "backend_pool_load_balancing" {
    for_each = var.backend_pools
    content {
      name = backend_pool_load_balancing.value.load_balancing.name
      sample_size = backend_pool_load_balancing.value.load_balancing.sample_size
      successful_samples_required = backend_pool_load_balancing.value.load_balancing.successful_samples_required
      additional_latency_milliseconds = backend_pool_load_balancing.value.load_balancing.additional_latency_ms
    }
  }

  backend_pool_settings {
    backend_pools_send_receive_timeout_seconds = lookup(var.backend_pool_settings, "backend_pools_send_receive_timeout_seconds", 60)
    enforce_backend_pools_certificate_name_check = lookup(var.backend_pool_settings, "enforce_backend_pools_certificate_name_check", false)
  }

  routing_rule {
    name               = "exampleRoutingRule1"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [replace(var.front_door_name, "-fd-", "-fdep-")]
    # One for each backend pool
    dynamic "forwarding_configuration" {
      for_each = var.forwarding_configurations
      content {
        backend_pool_name = forwarding_configuration.key
        cache_duration = forwarding_configuration.value.cache_duration
        cache_enabled = forwarding_configuration.value.cache_enabled
        cache_query_parameter_strip_directive = forwarding_configuration.value.cache_query_parameter_strip_directive
        cache_query_parameters = forwarding_configuration.value.cache_query_parameters
        cache_use_dynamic_compression = forwarding_configuration.value.cache_use_dynamic_compression
        custom_forwarding_path = forwarding_configuration.value.custom_forwarding_path
        forwarding_protocol = forwarding_configuration.value.forwarding_protocol
      }
    }
  }

  friendly_name = var.friendly_name
  load_balancer_enabled = var.load_balancer_enabled

  frontend_endpoint {
    name      = replace(var.front_door_name, "-fd-", "-fdep-")
    host_name = "${var.front_door_name}.azurefd.net"
  }

  tags = local.tags
}