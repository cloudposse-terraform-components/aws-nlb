variable "vpc_id" {
  type        = string
  description = "VPC ID to associate with NLB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs to associate with NLB"
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
  default     = ""
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
