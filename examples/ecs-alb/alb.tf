resource "aws_alb_target_group" "appserver" {
  name     = "nginx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}


resource "aws_alb" "main" {
  name            = "tf-alb-ecs"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.lb_sg.id}"]
}

resource "aws_alb_listener" "appserver" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.appserver.id}"
    type             = "forward"
  }
}
