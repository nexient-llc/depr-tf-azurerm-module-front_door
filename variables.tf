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

variable "forwarding_configurations" {
  description = "Routing rule configurations on how to forward the traffic to configured backends. Must contain an entry for each backend defined in backend_pool_name. Key should match the key of backend_pools"
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