output "alb" {
    value = aws_alb.utopia-alb
}

output "alb_dns" {
    value = aws_alb.utopia-alb.dns_name
}

output "alb_sg_id" {
    value = aws_security_group.alb_sg.id
}

output "alb_arn_suffix" {
    value = aws_alb.utopia-alb.arn_suffix
}

output "target_groups"{
    value = aws_alb_target_group.target_groups
}

output "booking_rule" {
    value = aws_lb_listener_rule.booking_listener
}

output "flight_rule" {
    value = aws_lb_listener_rule.flight_listener
}

