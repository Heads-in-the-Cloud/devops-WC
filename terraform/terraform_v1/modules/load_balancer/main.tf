
resource "aws_alb" "utopia-alb" {
    name = "utopia-alb-WC"
    subnets = var.public_subnet_ids
    security_groups = [ aws_security_group.alb_sg.id ]
    
}

resource "aws_alb_target_group" "target_groups" {
    for_each = var.target_groups
    name = each.value["name"]
    port = var.app_port
    protocol = each.value["protocol"]
    target_type = each.value["target_type"]
    vpc_id = var.vpc_id

    health_check {
        healthy_threshold = each.value["healthy_threshold"]
        interval = each.value["interval"]
        protocol = each.value["protocol"]
        matcher  = each.value["matcher"]
        timeout  = each.value["timeout"]
        path = each.value["health"]
        unhealthy_threshold = each.value["unhealthy_threshold"]
    }

}


resource "aws_alb_listener" "front_end" {
    load_balancer_arn = aws_alb.utopia-alb.id
    port = 80
    protocol = "HTTP"

    default_action {
    target_group_arn = aws_alb_target_group.target_groups["${var.user-tg}"].id

    type = "forward"
    }

}


resource "aws_lb_listener_rule" "flight_listener" {
  listener_arn = aws_alb_listener.front_end.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_groups["${var.flight-tg}"].id

  }

  condition {
    path_pattern {
      values = [ var.flights_path ]
    }
  }

}

resource "aws_lb_listener_rule" "booking_listener" {
  listener_arn = aws_alb_listener.front_end.arn
  priority     = 102

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_groups["${var.booking-tg}"].id
  }

  condition {
    path_pattern {
      values = [ var.bookings_path ]
    }
  }

}

resource "aws_lb_listener_rule" "frontend_listener" {
  listener_arn = aws_alb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_groups["${var.frontend-tg}"].id
  }

  condition {
    path_pattern {
      values = [ var.frontend_path ]
    }
  }

}

resource "aws_security_group" "alb_sg" {
  name        = "alb_sg_WC"
  description = "Allow all HTTP from any IPv4"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb_sg_WC"
  }
}

####################################################################
####################################################################
############################# ROUTE 53 #############################
####################################################################
####################################################################

data "aws_route53_zone" "zone" {
  name         = var.hosted_zone
}


resource "aws_route53_record" "route53" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = "walter.${data.aws_route53_zone.zone.name}"
  type    = "CNAME"
  ttl     = "300"
  records = [ aws_alb.utopia-alb.dns_name ]
}