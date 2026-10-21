output "nlb" {
  description = "The NLB of the Component"
  value       = one(module.nlb[*])
}

output "listeners" {
  description = "Additional listeners created from `var.listeners`, keyed by listener name"
  value = {
    for key, listener in aws_lb_listener.listener : key => {
      listener_arn      = listener.arn
      port              = listener.port
      protocol          = listener.protocol
      target_group_arn  = aws_lb_target_group.listener[key].arn
      target_group_name = aws_lb_target_group.listener[key].name
    }
  }
}
