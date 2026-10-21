locals {
  listeners = local.enabled ? var.listeners : {}

  listeners_vpc_id = local.enabled ? coalesce(var.vpc_id, one(module.vpc[*].outputs.vpc_id)) : null

  # Security group protocols for each listener protocol. TCP_UDP needs a rule per protocol.
  listener_sg_protocols = {
    TCP     = ["tcp"]
    TLS     = ["tcp"]
    UDP     = ["udp"]
    TCP_UDP = ["tcp", "udp"]
  }

  listener_ingress_rules = {
    for rule in flatten([
      for key, listener in local.listeners : [
        for protocol in local.listener_sg_protocols[listener.protocol] : {
          key         = "${key}-${protocol}"
          port        = listener.port
          protocol    = protocol
          cidr_blocks = listener.ingress_cidr_blocks
          description = "${key} listener (${upper(protocol)} ${listener.port})"
        }
      ] if length(listener.ingress_cidr_blocks) > 0
    ]) : rule.key => rule
  }

  listener_target_attachments = {
    for attachment in flatten([
      for key, listener in local.listeners : [
        for target in listener.targets : {
          key       = "${key}/${target.id}/${coalesce(target.port, listener.target_port, listener.port)}"
          listener  = key
          target_id = target.id
          port      = coalesce(target.port, listener.target_port, listener.port)
        }
      ]
    ]) : attachment.key => attachment
  }
}

module "listener_target_group_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  for_each = local.listeners

  attributes      = [each.key]
  id_length_limit = var.target_group_name_max_length

  context = module.this.context
}

resource "aws_lb_target_group" "listener" {
  for_each = local.listeners

  name                 = module.listener_target_group_label[each.key].id
  port                 = coalesce(each.value.target_port, each.value.port)
  protocol             = coalesce(each.value.target_protocol, each.value.protocol == "TLS" ? "TCP" : each.value.protocol)
  target_type          = coalesce(each.value.target_type, var.target_group_target_type)
  vpc_id               = local.listeners_vpc_id
  preserve_client_ip   = each.value.preserve_client_ip
  deregistration_delay = coalesce(each.value.deregistration_delay, var.deregistration_delay)

  health_check {
    enabled             = each.value.health_check.enabled
    port                = each.value.health_check.port
    protocol            = each.value.health_check.protocol
    path                = each.value.health_check.path
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    interval            = each.value.health_check.interval
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = module.listener_target_group_label[each.key].tags
}

resource "aws_lb_listener" "listener" {
  for_each = local.listeners

  load_balancer_arn = module.nlb[0].nlb_arn
  port              = each.value.port
  protocol          = each.value.protocol
  certificate_arn   = each.value.protocol == "TLS" ? coalesce(each.value.certificate_arn, var.certificate_arn, local.certificate_arn) : null
  ssl_policy        = each.value.protocol == "TLS" ? each.value.ssl_policy : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.listener[each.key].arn
  }

  tags = module.listener_target_group_label[each.key].tags
}

resource "aws_lb_target_group_attachment" "listener" {
  for_each = local.listener_target_attachments

  target_group_arn = aws_lb_target_group.listener[each.value.listener].arn
  target_id        = each.value.target_id
  port             = each.value.port
}

resource "aws_security_group_rule" "listener_ingress" {
  for_each = local.listener_ingress_rules

  type              = "ingress"
  security_group_id = module.nlb[0].security_group_id
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  description       = each.value.description

  lifecycle {
    precondition {
      condition     = var.security_group_enabled
      error_message = "listeners[*].ingress_cidr_blocks requires security_group_enabled = true (the rules are added to the NLB security group created by the module)."
    }
  }
}
