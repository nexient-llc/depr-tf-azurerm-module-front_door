resource "azurerm_frontdoor" "front_door" {
  name                = var.front_door_name
  resource_group_name = var.resource_group.name

  dynamic "backend_pool" {
    for_each = var.backend_pools
    content {
      name                = backend_pool.key
      load_balancing_name = backend_pool.value.load_balancing.name
      health_probe_name   = backend_pool.value.health_probe.name

      dynamic "backend" {
        for_each = backend_pool.value.backends
        content {
          enabled     = backend.value.enabled
          address     = backend.value.address
          host_header = backend.value.host_header
          http_port   = backend.value.http_port
          https_port  = backend.value.https_port
          priority    = backend.value.priority
          weight      = backend.value.weight
        }
      }
    }
  }

  dynamic "backend_pool_health_probe" {
    for_each = var.backend_pools
    content {
      enabled      = backend_pool_health_probe.value.health_probe.enabled
      name         = backend_pool_health_probe.value.health_probe.name
      path         = backend_pool_health_probe.value.health_probe.path
      protocol     = backend_pool_health_probe.value.health_probe.protocol
      probe_method = backend_pool_health_probe.value.health_probe.probe_method
    }
  }

  dynamic "backend_pool_load_balancing" {
    for_each = var.backend_pools
    content {
      name                            = backend_pool_load_balancing.value.load_balancing.name
      sample_size                     = backend_pool_load_balancing.value.load_balancing.sample_size
      successful_samples_required     = backend_pool_load_balancing.value.load_balancing.successful_samples_required
      additional_latency_milliseconds = backend_pool_load_balancing.value.load_balancing.additional_latency_ms
    }
  }

  backend_pool_settings {
    backend_pools_send_receive_timeout_seconds   = lookup(var.backend_pool_settings, "backend_pools_send_receive_timeout_seconds", 60)
    enforce_backend_pools_certificate_name_check = lookup(var.backend_pool_settings, "enforce_backend_pools_certificate_name_check", false)
  }

  # Currently supports only 1 routing rule

  dynamic "routing_rule" {
    for_each = local.routing_rules
    content {
      name               = routing_rule.value.name
      frontend_endpoints = routing_rule.value.frontend_endpoint_names
      accepted_protocols = routing_rule.value.accepted_protocols
      patterns_to_match  = routing_rule.value.patterns_to_match
      enabled            = routing_rule.value.enabled
      dynamic "forwarding_configuration" {
        for_each = routing_rule.value.forwarding_configuration
        content {
          backend_pool_name                     = forwarding_configuration.key
          cache_duration                        = forwarding_configuration.value.cache_duration
          cache_enabled                         = forwarding_configuration.value.cache_enabled
          cache_query_parameter_strip_directive = forwarding_configuration.value.cache_query_parameter_strip_directive
          cache_query_parameters                = forwarding_configuration.value.cache_query_parameters
          cache_use_dynamic_compression         = forwarding_configuration.value.cache_use_dynamic_compression
          custom_forwarding_path                = forwarding_configuration.value.custom_forwarding_path
          forwarding_protocol                   = forwarding_configuration.value.forwarding_protocol
        }
      }
      dynamic "redirect_configuration" {
        for_each = routing_rule.value.redirect_configuration != null ? [1] : []
        content {
          custom_host         = lookup(routing_rule.value.redirect_configuration, "custom_host", null)
          redirect_protocol   = lookup(routing_rule.value.redirect_configuration, "redirect_protocol", "MatchRequest")
          redirect_type       = lookup(routing_rule.value.redirect_configuration, "redirect_type", "")
          custom_fragment     = lookup(routing_rule.value.redirect_configuration, "custom_fragment", null)
          custom_path         = lookup(routing_rule.value.redirect_configuration, "custom_path", null)
          custom_query_string = lookup(routing_rule.value.redirect_configuration, "custom_query_string", null)
        }
      }
    }
  }

  friendly_name         = var.friendly_name
  load_balancer_enabled = var.load_balancer_enabled

  frontend_endpoint {
    name      = local.default_frontend_endpoint.name
    host_name = local.default_frontend_endpoint.host_name
  }

  dynamic "frontend_endpoint" {
    for_each = var.frontend_endpoints
    content {
      name      = frontend_endpoint.value.endpoint_name
      host_name = frontend_endpoint.value.create_record ? "${frontend_endpoint.value.record_name}.${frontend_endpoint.value.dns_zone}" : frontend_endpoint.value.record_name
    }
  }

  tags = local.tags

  depends_on = [
    azurerm_dns_cname_record.cname_record
  ]
}

data "azurerm_key_vault" "key_vault" {
  for_each            = var.custom_user_managed_certs
  name                = each.value.key_vault_name
  resource_group_name = each.value.key_vault_rg
}

# The endpoints must exist before configuring the https
resource "azurerm_frontdoor_custom_https_configuration" "custom_https" {
  for_each = var.custom_user_managed_certs

  frontend_endpoint_id              = local.frontend_endpoints_map[each.key]
  custom_https_provisioning_enabled = each.value.https_enabled

  dynamic "custom_https_configuration" {
    for_each = each.value.https_enabled ? [1] : []
    content {
      certificate_source                         = "AzureKeyVault"
      azure_key_vault_certificate_secret_name    = each.value.certificate_secret_name
      azure_key_vault_certificate_vault_id       = data.azurerm_key_vault.key_vault[each.key].id
      azure_key_vault_certificate_secret_version = coalesce(each.value.certificate_secret_version, "notset") != "notset" ? each.value.certificate_secret_version : null
    }
  }

  depends_on = [
    azurerm_frontdoor.front_door
  ]
}

# Needs to be created before the frontend_endpoints are created
resource "azurerm_dns_cname_record" "cname_record" {
  for_each = local.create_cname_for_endpoints

  name                = each.value.record_name
  zone_name           = each.value.dns_zone
  resource_group_name = each.value.dns_rg
  ttl                 = 300
  record              = "${var.front_door_name}.azurefd.net"
}