locals {
  enabled = module.this.enabled

  dns_delegated_outputs             = module.dns_delegated.outputs
  dns_delegated_default_domain_name = local.dns_delegated_outputs.default_domain_name
  dns_delegated_certificate         = local.dns_delegated_outputs.certificate
  dns_delegated_certificate_obj     = lookup(local.dns_delegated_certificate, local.dns_delegated_default_domain_name, {})
  dns_delegated_certificate_arn     = lookup(local.dns_delegated_certificate_obj, "arn", "")

  certificate_arn = var.dns_acm_enabled ? module.acm.outputs.arn : local.dns_delegated_certificate_arn
}

module "nlb" {
  count = local.enabled ? 1 : 0

  source  = "cloudposse/nlb/aws"
  version = "0.18.2"

  enabled = local.enabled

  vpc_id                        = coalesce(var.vpc_id, one(module.vpc[*].outputs.vpc_id))
  subnet_ids                    = coalesce(var.subnet_ids, var.internal ? one(module.vpc[*].outputs.private_subnet_ids) : one(module.vpc[*].outputs.public_subnet_ids))
  security_group_ids            = var.security_group_ids
  internal                      = var.internal
  load_balancer_name            = var.load_balancer_name
  load_balancer_name_max_length = var.load_balancer_name_max_length
  subnet_mapping_enabled        = var.subnet_mapping_enabled
  eip_allocation_ids            = var.eip_allocation_ids

  target_group_enabled              = var.target_group_enabled
  target_group_name                 = var.target_group_name
  target_group_name_max_length      = var.target_group_name_max_length
  target_group_port                 = var.target_group_port
  target_group_target_type          = var.target_group_target_type
  target_group_ip_address_type      = var.target_group_ip_address_type
  tcp_port                          = var.tcp_port
  tcp_enabled                       = var.tcp_enabled
  tls_enabled                       = var.tls_enabled
  tls_port                          = var.tls_port
  certificate_arn                   = coalesce(var.certificate_arn, local.certificate_arn, "false") == "false" ? null : coalesce(var.certificate_arn, local.certificate_arn)
  udp_enabled                       = var.udp_enabled
  udp_port                          = var.udp_port
  cross_zone_load_balancing_enabled = var.cross_zone_load_balancing_enabled
  deletion_protection_enabled       = var.deletion_protection_enabled
  deregistration_delay              = var.deregistration_delay
  health_check_enabled              = var.health_check_enabled
  health_check_port                 = var.health_check_port
  stickiness_enabled                = var.stickiness_enabled
  access_logs_enabled               = var.access_logs_enabled

  context = module.this.context
}
