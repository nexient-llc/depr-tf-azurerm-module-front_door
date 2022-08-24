# Common Variables
variable "resource_group" {
  description = "target resource group resource mask"
  type = object({
    name     = string
    location = string
  })
  default = {
    name     = "deb-test-devops"
    location = "eastus"
  }
}

# Front Door related variables 

variable "front_door_name" {
  description = "Name of the front-door"
  type        = string
}

variable "friendly_name" {
  description = "A friendly name to be attached to the front-door"
  default     = ""
  type        = string
}

variable "load_balancer_enabled" {
  description = "Whether the load balancer is enabled"
  type        = bool
  default     = true
}

variable "custom_tags" {
  description = "Custom tags to be attached to the front-door"
  type        = map(string)
  default     = {}

}

variable "backend_pools" {
  description = "A map of backend pools. Front-door supports a maximum of 50 pools. Each pool must have at least one backend (enabled). Each backend must have a health probe and a load balancing"
  type = map(object({
    backends = map(object({
      enabled     = bool
      address     = string
      host_header = string
      http_port   = number
      https_port  = number
      priority    = number
      weight      = number
    }))
    health_probe = object({
      enabled      = bool
      name         = string
      path         = string
      protocol     = string
      probe_method = string
    })
    load_balancing = object({
      name                        = string
      sample_size                 = number # defaults to 4
      successful_samples_required = number # defaults to 2
      additional_latency_ms       = number # defaults to 0
    })
  }))


}

# Front-end configuration for custom domains
variable "frontend_endpoints" {
  description = "Custom domain names to be attached to the front-door instance. The DNS records will be created if create_record=true. record_name must be a fqdn if create_record=false (DNS record must be created outside terraform pointing to the front-door instance), else it should be without the zone_name"
  type = map(object({
    create_record = bool
    endpoint_name = string
    record_name   = string # test1 if create_record=true, test1.nexient.com if create_record=false
    record_type   = string
    dns_zone      = string
    dns_rg        = string
  }))

  default = {}
}

# Primary Routing rule related variables

variable "routing_rule_name" {
  description = "Name of the routing rule"
  type        = string
  default     = "default-routing-rule"
}

variable "frontend_endpoint_names" {
  description = "A list of front-end endpoints for the Front-door. May be empty if no custom domain names attached. The default endpoint will be constructed in the locals file"
  type        = list(string)
  default     = []
}

variable "accepted_protocols" {
  description = "Protocol schemes to match for the Backend Routing Rule. Defaults to Http"
  type        = list(string)
  default     = ["Http"]
}

variable "patterns_to_match" {
  description = "The route patterns for the Backend Routing Rule. Defaults to /*"
  type        = list(string)
  default     = ["/*"]
}

variable "routing_rule_enabled" {
  description = "Whether the routing rule should be enabled. Default is enabled. Cannot be disabled unless there are other routing rule enabled"
  type        = bool
  default     = true
}

variable "forwarding_configurations" {
  description = "Routing rules to forward the traffic to configured backends. Must contain an entry for each backend_pool defined in variable 'backend_pool' (key should match the key of backend_pools)."
  type = map(object({
    cache_enabled                         = bool         # defaults to false
    cache_use_dynamic_compression         = bool         # defaults to false
    cache_query_parameter_strip_directive = string       # defaults to StripAll
    cache_query_parameters                = list(string) # works only with strip_directive = StringOnly or StripAllExcept
    cache_duration                        = string       # number between 0 and 365. Works only when cache_enabled = true
    custom_forwarding_path                = string
    forwarding_protocol                   = string # defaults to HttpsOnly
  }))

}

variable "redirect_configurations" {
  description = "Routing rules to redirect the traffic to the configured backend"
  type = object({
    custom_host         = string
    redirect_protocol   = string # defaults to MatchRequest
    redirect_type       = string # valid options are Moved, Found, TemporaryRedirect, PermanentRedirect
    custom_fragment     = string
    custom_path         = string
    custom_query_string = string
  })

  default = null

}

variable "additional_routing_rules" {
  description = "Optional additional routing rules for the Front Door (One routing rule named 'primary' will be created by default based on the variables defined above). Multiple routing rules cannot have same set of AcceptedProtocol, FrontendEndpoint, and PatternsToMatch"
  type = map(object({
    name                    = string
    frontend_endpoint_names = list(string) #The first end point should be <front_door_name>.azurefd.net. The others can be list of custom domains if any
    accepted_protocols      = list(string)
    patterns_to_match       = list(string)
    enabled                 = bool
    forwarding_configuration = map(object({
      cache_enabled                         = bool         # defaults to false
      cache_use_dynamic_compression         = bool         # defaults to false
      cache_query_parameter_strip_directive = string       # defaults to StripAll
      cache_query_parameters                = list(string) # works only with strip_directive = StringOnly or StripAllExcept
      cache_duration                        = string       # number between 0 and 365. Works only when cache_enabled = true
      custom_forwarding_path                = string
      forwarding_protocol                   = string # defaults to HttpsOnly
    }))
    redirect_configuration = object({
      custom_host         = string
      redirect_protocol   = string # defaults to MatchRequest
      redirect_type       = string # valid options are Moved, Found, TemporaryRedirect, PermanentRedirect
      custom_fragment     = string
      custom_path         = string
      custom_query_string = string
    })
  }))

  default = {}
}

variable "backend_pool_settings" {
  description = "Settings for the backend pool of frontdoor. These settings are common for all backend pools"
  type = object({
    backend_pools_send_receive_timeout_seconds   = number
    enforce_backend_pools_certificate_name_check = bool
  })
  default = {
    backend_pools_send_receive_timeout_seconds   = 60
    enforce_backend_pools_certificate_name_check = false
  }
}