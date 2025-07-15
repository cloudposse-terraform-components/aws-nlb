output "nlb_name" {
  description = "Name of the NLB"
  value       = module.nlb.nlb_name
}

output "nlb_arn" {
  description = "ARN of the NLB"
  value       = module.nlb.nlb_arn
}

output "nlb_dns_name" {
  description = "DNS name of the NLB"
  value       = module.nlb.nlb_dns_name
}

output "nlb_zone_id" {
  description = "Canonical hosted zone ID for the NLB"
  value       = module.nlb.nlb_zone_id
}

output "security_group_id" {
  description = "Security group ID created for the NLB"
  value       = module.nlb.security_group_id
}

output "default_listener_arn" {
  description = "ARN of the default listener"
  value       = module.nlb.default_listener_arn
}

output "default_target_group_arn" {
  description = "ARN of the default target group"
  value       = module.nlb.default_target_group_arn
}
