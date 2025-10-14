output "nlb" {
  description = "The NLB of the Component"
  value       = one(module.nlb[*])
}

output "nlb_arn" {
  description = "The ARN of the NLB"
  value       = one(module.nlb[*].arn)
}
