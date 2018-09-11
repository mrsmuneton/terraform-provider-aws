
resource "aws_ecs_cluster" "main" {
  name = "userpics-cluster"
}

data "template_file" "template_app_server" {
  template = "${file("${path.module}/app-server-task.json")}"

  vars {
    nginx_image_url      = "${var.nginx_repository_uri}:${var.nginx_tag}"
    php_image_url        = "${var.php_app_repository_uri}:${var.php_app_tag}"
    php_container_name   = "phpapp"
    nginx_container_name = "nginx"
    log_group_region     = "${var.aws_region}"
    php_log_group_name   = "${aws_cloudwatch_log_group.php.name}"
    nginx_log_group_name = "${aws_cloudwatch_log_group.nginx.name}"
    db_host              = "${aws_db_instance.main.address}"
    db_port              = "${aws_db_instance.main.port}"
    db_name              = "userimages"
    db_username          = "mysqluser"
    db_password          = "${var.password}"
    aws_region           = "${var.aws_region}"
    bucket_name          = "${var.bucket_name}"
  }
}

resource "aws_ecs_task_definition" "appserver" {
  family                = "appserver"
  container_definitions = "${data.template_file.template_app_server.rendered}"
}

resource "aws_ecs_service" "ecs-appserver" {
  name            = "tf-ecs-appserver"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.appserver.arn}"
  desired_count   = "${var.desired_task_count}"
  iam_role        = "${aws_iam_role.ecs_service.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.appserver.id}"
    container_name   = "nginx"
    container_port   = "80"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.appserver",
  ]
}

resource "aws_launch_configuration" "lc" {
  security_groups = [
    "${aws_security_group.instance_sg.id}",
  ]

  key_name                    = "${var.key_name}"
  image_id                    = "${data.aws_ami.aws_optimized_ecs.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.nginx.name}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }

  user_data                   = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.id} >> /etc/ecs/ecs.config
EOF
}

data "template_file" "instance_profile" {
  template = "${file("${path.module}/instance-profile-policy.json")}"

  vars {
    nginx_log_group_arn = "${aws_cloudwatch_log_group.nginx.arn}"
    phpapp_log_group_arn = "${aws_cloudwatch_log_group.php.arn}"
    ecs_log_group_arn = "${aws_cloudwatch_log_group.ecs.arn}"
    nginx_ecr_arn = "${var.nginx_repository_arn}"
    php_app_ecr_arn = "${var.php_app_repository_arn}"
  }
}

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
