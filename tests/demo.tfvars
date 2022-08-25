front_door_name = "demo-eus-dev-000-fd-000"

resource_group = {
  name = "deb-test-devops"
  location = "eastus"
}

backend_pools = {
  "dummy-backend-pool" = {
    backends = {
      backend-1 = {
        address = "demo-eus-dev-000-app-000.azurewebsites.net"
        enabled = true
        host_header = "demo-eus-dev-000-app-000.azurewebsites.net"
        http_port = 80
        https_port = 443
        priority = 1
        weight = 50
      }
    }
    health_probe = {
      enabled = false
      path = "/"
      name = "dummy-health-probe"
      probe_method = "GET"
      protocol = "Https"
    }
    load_balancing = {
      name = "dummy-load-balancer"
      sample_size = 4
      successful_samples_required = 2
      additional_latency_ms = 0
    }
  }
}
forwarding_configurations = {
  "dummy-backend-pool" = {
    cache_duration = null
    cache_enabled = false
    cache_query_parameter_strip_directive = "StripAll"
    cache_query_parameters = []
    cache_use_dynamic_compression = false
    custom_forwarding_path = ""
    forwarding_protocol = "MatchRequest"
  }
}

frontend_endpoint_names = ["demo-eus-dev-000-fdep-000"]

additional_routing_rules = {
  "routing-rule-1" = {
    accepted_protocols = [ "Http", "Https"]
    enabled = false
    forwarding_configuration = {
      "dummy-backend-pool" = {
        cache_duration = null
        cache_enabled = false
        cache_query_parameter_strip_directive = "StripAll"
        cache_query_parameters = []
        cache_use_dynamic_compression = false
        custom_forwarding_path = ""
        forwarding_protocol = "MatchRequest"
      }
    }
    frontend_endpoint_names = ["demo-eus-dev-000-fdep-000"]
    name = "routing-rule-1"
    patterns_to_match = [ "/test" ]
    redirect_configuration = null
  }
}

frontend_endpoints = {
  api-test2-vanillavc-com = {
    create_record = false
    endpoint_name = "api-test2-vanillavc-com"
    record_name = "api-test2.vanillavc.com"
    record_type = "CNAME"
    dns_zone = null
    dns_rg = null
  }
  azurecdn-dsahoo-com = {
    create_record = false
    endpoint_name = "azurecdn-dsahoo-com"
    record_name = "azurecdn.dsahoo.com"
    record_type = "CNAME"
    dns_zone = null
    dns_rg = null
  }
  azurecdn2-dsahoo-com = {
    create_record = false
    endpoint_name = "azurecdn2-dsahoo-com"
    record_name = "azurecdn2.dsahoo.com"
    record_type = "CNAME"
    dns_zone = null
    dns_rg = null
  }
}

custom_user_managed_certs = {
    "azurecdn-dsahoo-com" = {
      certificate_secret_name = "azurecdn-dsahoo-com"
      certificate_secret_version = ""
      https_enabled = true
      key_vault_name = "deb-test-akv-000"
      key_vault_rg = "deb-test-devops"
    }
    "azurecdn2-dsahoo-com" = {
      certificate_secret_name = "azurecdn2-dsahoo-com"
      certificate_secret_version = ""
      https_enabled = true
      key_vault_name = "deb-test-akv-000"
      key_vault_rg = "deb-test-devops"
    }
  }