output "nlb" {
  description = "The NLB of the Component"
  value       = one(module.nlb[*])
}
