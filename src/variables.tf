variable "region" {
  type        = string
  description = "AWS Region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate with NLB"
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to associate with NLB"
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  default     = []
  description = "Additional security group IDs to allow access to the NLB"
}

variable "internal" {
  type        = bool
  default     = false
  description = "Whether the NLB is internal"
}

variable "load_balancer_name" {
  type        = string
  default     = ""
  description = "Name for the load balancer"
}

variable "load_balancer_name_max_length" {
  type        = number
  default     = 32
  description = "Max length for the load balancer name"
}

variable "subnet_mapping_enabled" {
  type        = bool
  default     = false
  description = "Create EIPs for the provided subnet IDs"
}

variable "eip_allocation_ids" {
  type        = list(string)
  default     = []
  description = "Allocation IDs for EIPs when subnet mapping is enabled"
}

variable "target_group_enabled" {
  type        = bool
  default     = true
  description = "Whether to create the default target group and listener"
}

variable "target_group_name" {
  type        = string
  default     = ""
  description = "Name of the default target group"
}

variable "target_group_name_max_length" {
  type        = number
  default     = 32
  description = "Max length for the target group name"
}

variable "target_group_port" {
  type        = number
  default     = 80
  description = "Port for the default target group"
}

variable "target_group_target_type" {
  type        = string
  default     = "ip"
  description = "Target type for the default target group"
}

variable "target_group_ip_address_type" {
  type        = string
  default     = "ipv4"
  description = "IP address type for the target group"
}

variable "tcp_port" {
  type        = number
  default     = 80
  description = "Port for the TCP listener"
}

variable "tcp_enabled" {
  type        = bool
  default     = true
  description = "Enable the TCP listener"
}

variable "tls_enabled" {
  type        = bool
  default     = false
  description = "Enable the TLS listener"
}

variable "tls_port" {
  type        = number
  default     = 443
  description = "Port for the TLS listener"
}

variable "certificate_arn" {
  type        = string
  default     = null
  description = "ARN of the certificate for the TLS listener"
}

variable "udp_enabled" {
  type        = bool
  default     = false
  description = "Enable the UDP listener"
}

variable "udp_port" {
  type        = number
  default     = 53
  description = "Port for the UDP listener"
}

variable "cross_zone_load_balancing_enabled" {
  type        = bool
  default     = true
  description = "Enable cross zone load balancing"
}

variable "deletion_protection_enabled" {
  type        = bool
  default     = false
  description = "Enable deletion protection for the NLB"
}

variable "deregistration_delay" {
  type        = number
  default     = 15
  description = "Time to wait before deregistering targets"
}

variable "health_check_enabled" {
  type        = bool
  default     = true
  description = "Enable health checks"
}

variable "health_check_port" {
  type        = number
  default     = null
  description = "Port for health checks"
}

variable "stickiness_enabled" {
  type        = bool
  default     = false
  description = "Enable stickiness on the default target group"
}

variable "vpc_component_name" {
  type        = string
  description = "Name of the VPC component"
  default     = "vpc"
}

variable "dns_delegated_component_name" {
  type        = string
  default     = "dns-delegated"
  description = "Atmos `dns-delegated` component name"
}

variable "dns_delegated_environment_name" {
  type        = string
  default     = null
  description = "`dns-delegated` component environment name"
}

variable "acm_component_name" {
  type        = string
  default     = "acm"
  description = "Atmos `acm` component name"
}

variable "dns_acm_enabled" {
  type        = bool
  default     = false
  description = "If `true`, use the ACM ARN created by the given `dns-delegated` component. Otherwise, use the ACM ARN created by the given `acm` component. Overridden by `certificate_arn`"
}

variable "access_logs_enabled" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable access_logs"
}

variable "security_group_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    Whether the module creates a security group for the NLB. Required for `listeners[*].ingress_cidr_blocks`.
    An NLB security group can only be attached when the NLB is created, so enabling this on an existing NLB replaces it.
    EOT
}

variable "listeners" {
  type = map(object({
    port                 = number
    protocol             = optional(string, "TCP")
    target_port          = optional(number)
    target_protocol      = optional(string)
    target_type          = optional(string)
    preserve_client_ip   = optional(bool)
    deregistration_delay = optional(number)
    certificate_arn      = optional(string)
    ssl_policy           = optional(string)
    ingress_cidr_blocks  = optional(list(string), [])
    health_check = optional(object({
      enabled             = optional(bool, true)
      port                = optional(string, "traffic-port")
      protocol            = optional(string, "TCP")
      path                = optional(string)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      interval            = optional(number, 30)
    }), {})
    targets = optional(list(object({
      id   = string
      port = optional(number)
    })), [])
  }))
  default     = {}
  description = <<-EOT
    Additional listeners, keyed by name. Each key creates its own target group and listener on the NLB,
    so one NLB can serve any number of ports. Independent of the default listener (`tcp_*`/`udp_*`/`tls_*`);
    set `target_group_enabled = false` to use only these.
    - `port`: listener port. `protocol`: `TCP`, `UDP`, `TCP_UDP` or `TLS`.
    - `target_port`/`target_protocol`: defaults to `port` and to `protocol` (`TCP` for a `TLS` listener).
    - `target_type`: defaults to `target_group_target_type`.
    - `certificate_arn`: `TLS` only; defaults to `certificate_arn`, then the ACM / dns-delegated certificate.
    - `ingress_cidr_blocks`: CIDRs allowed on the NLB security group for this port (needs `security_group_enabled`).
    - `health_check.protocol`: `TCP`, `HTTP` or `HTTPS` (`UDP` target groups cannot use a UDP health check).
    - `targets`: optional target registrations (instance ID, IP or Lambda ARN, matching `target_type`).
    EOT

  validation {
    condition     = alltrue([for l in values(var.listeners) : contains(["TCP", "UDP", "TCP_UDP", "TLS"], l.protocol)])
    error_message = "listeners[*].protocol must be one of TCP, UDP, TCP_UDP or TLS."
  }

  validation {
    condition     = length(distinct([for l in values(var.listeners) : l.port])) == length(var.listeners)
    error_message = "listeners[*].port must be unique across listeners."
  }

  validation {
    condition     = alltrue([for l in values(var.listeners) : contains(["TCP", "HTTP", "HTTPS"], l.health_check.protocol)])
    error_message = "listeners[*].health_check.protocol must be one of TCP, HTTP or HTTPS."
  }
}
