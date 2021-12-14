output "alb" {
    value = aws_alb.utopia-alb
}

output "alb_sg_id" {
    value = aws_security_group.alb_sg.id
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

# output "user_tg_id" {
#     value = aws_alb_target_group.target_groups["user-tg"].id
# }

# output "flight_tg_id" {
#     value = aws_alb_target_group.target_groups["flight-tg"].id
# }

# output "booking_tg_id" {
#     value = aws_alb_target_group.target_groups["booking-tg"].id
# }