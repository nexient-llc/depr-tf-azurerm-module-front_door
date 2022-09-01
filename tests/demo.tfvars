front_door_name = "demo-eus-dev-000-fd-003"

resource_group = {
  name     = "deb-test-devops"
  location = "eastus"
}

backend_pools = {
  "dummy-backend-pool" = {
    backends = {
      backend-1 = {
        address     = "demo-eus-dev-000-app-003.azurewebsites.net"
        enabled     = true
        host_header = "demo-eus-dev-000-app-003.azurewebsites.net"
        http_port   = 80
        https_port  = 443
        priority    = 1
        weight      = 50
      }
    }
    health_probe = {
      enabled      = false
      path         = "/"
      name         = "dummy-health-probe"
      probe_method = "GET"
      protocol     = "Https"
    }
    load_balancing = {
      name                        = "dummy-load-balancer"
      sample_size                 = 4
      successful_samples_required = 2
      additional_latency_ms       = 0
    }
  }
}
forwarding_configurations = {
  "dummy-backend-pool" = {
    cache_duration                        = null
    cache_enabled                         = false
    cache_query_parameter_strip_directive = "StripAll"
    cache_query_parameters                = []
    cache_use_dynamic_compression         = false
    custom_forwarding_path                = ""
    forwarding_protocol                   = "MatchRequest"
  }
}

accepted_protocols = ["Http", "Https"]

frontend_endpoint_names = ["demo-eus-dev-000-fdep-003"]


frontend_endpoints = {

}
