# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

## EC2

### Network

data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "www2gateway" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "www to ig"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.subnet_1.id}"
  route_table_id = "${aws_route_table.www2gateway.id}"
}

resource "aws_route_table_association" "b" {
  subnet_id      = "${aws_subnet.subnet_2.id}"
  route_table_id = "${aws_route_table.www2gateway.id}"
}

resource "aws_eip" "nat1" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "ngw1" {
  allocation_id = "${aws_eip.nat1.id}"
  subnet_id     = "${aws_subnet.subnet_1.id}"

  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name = "subnet_3 NAT"
  }
}

resource "aws_eip" "nat2" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "ngw2" {
  allocation_id = "${aws_eip.nat2.id}"
  subnet_id     = "${aws_subnet.subnet_2.id}"

  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name = "subnet_4 NAT"
  }
}

resource "aws_route_table" "nat_1" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.ngw1.id}"
  }

  tags {
    Name = "private 1"
  }
}

resource "aws_route_table" "nat_2" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.ngw2.id}"
  }

  tags {
    Name = "private 2"
  }
}

resource "aws_route_table_association" "c" {
  subnet_id      = "${aws_subnet.subnet_3.id}"
  route_table_id = "${aws_route_table.nat_1.id}"
}

resource "aws_route_table_association" "d" {
  subnet_id      = "${aws_subnet.subnet_4.id}"
  route_table_id = "${aws_route_table.nat_2.id}"
}
### Compute

resource "aws_autoscaling_group" "asg" {
  name                 = "tf-asg"
  vpc_zone_identifier  = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.lc.name}"

  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }
}

data "template_file" "cloud_config" {
  template = "${file("${path.module}/cloud-config.yml")}"

  vars {
    aws_region         = "${var.aws_region}"
    ecs_cluster_name   = "${aws_ecs_cluster.main.name}"
    ecs_log_level      = "info"
    ecs_agent_version  = "latest"
    ecs_log_group_name = "${aws_cloudwatch_log_group.ecs.name}"
  }
}

data "aws_ami" "ami" {
  most_recent      = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_launch_configuration" "lc" {
  security_groups = [
    "${aws_security_group.instance_sg.id}",
  ]

  key_name                    = "${var.key_name}"
  image_id                    = "${data.aws_ami.ami.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.instance_profile.name}"
  user_data                   = "${data.template_file.cloud_config.rendered}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

### Security

resource "aws_security_group" "lb_sg" {
  description = "controls access to the application ELB"

  vpc_id = "${aws_vpc.main.id}"
  name   = "tf-ecs-lbsg"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags {
    Name = "lb"
  }
}

resource "aws_security_group" "instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = "${aws_vpc.main.id}"
  name        = "tf-ecs-instsg"

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80

    security_groups = [
      "${aws_security_group.lb_sg.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "instance"
  }
}

## ECS

resource "aws_ecs_cluster" "main" {
  name = "userpics-cluster"
}

data "template_file" "template_app_server" {
  template = "${file("${path.module}/app-server-task.json")}"

  vars {
    nginx_image_url      = "${var.nginx_repository_uri}:${var.nginx_tag}"
    php_image_url        = "${var.php_app_repositiry_uri}:${var.php_app_repositiry_uri}"
    php_container_name   = "phpapp"
    nginx_container_name = "nginx"
    log_group_region     = "${var.aws_region}"
    php_log_group_name   = "${aws_cloudwatch_log_group.php.name}"
    nginx_log_group_name = "${aws_cloudwatch_log_group.nginx.name}"
    db_host              = "${aws_db_instance.default.address}"
    db_port              = "${aws_db_instance.default.port}"
    db_name              = "${var.db_name}"
    db_username          = "${var.db_username}"
    db_password          = "${var.db_password}"
    aws_region           = "${var.aws_region}"
    bucket_name           = "${var.bucket_name}"
  }
}

resource "aws_ecs_task_definition" "appserver" {
  family                = "appserver_td"
  container_definitions = "${data.template_file.template_app_server.rendered}"
  task_role_arn         = "${aws_iam_role.task_role.arn}"
}

resource "aws_ecs_service" "ecs-appserver" {
  name            = "tf-ecs-appserver"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.appserver.arn}"
  desired_count   = "${var.task_count_desired}"
  iam_role        = "${aws_iam_role.ecs_service_role.arn}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.appserver.id}"
    container_name   = "nginx"
    container_port   = "80"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_task_policy",
    "aws_alb_listener.appserver",
  ]
}

## IAM

resource "aws_iam_role" "task_role" {
  name = "tf_task_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "tf_task_policy"
  role = "${aws_iam_role.task_role.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:Describe*",
                "autoscaling:UpdateAutoScalingGroup",
                "cloudformation:CreateStack",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStack*",
                "cloudformation:UpdateStack",
                "cloudwatch:GetMetricStatistics",
                "ec2:Describe*",
                "elasticloadbalancing:*",
                "ecs:*",
                "events:DescribeRule",
                "events:DeleteRule",
                "events:ListRuleNamesByTarget",
                "events:ListTargetsByRule",
                "events:PutRule",
                "events:PutTargets",
                "events:RemoveTargets",
                "iam:ListInstanceProfiles",
                "iam:ListRoles",
                "iam:PassRole"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecs_service_role" {
  name = "tf_ecs_role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "ecs_service_policy" {
  name = "tf_ecs_policy"
  role = "${aws_iam_role.ecs_service_role.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:*",
        "ec2:*",
        "ecs:*"
      ],
      "Resource": "*"
    },
    {
      "Effect":"Allow",
      "Action":["s3:*"],
      "Resource":["arn:aws:s3:::userpics-sre-eval/*"]
    },
    {
       "Effect": "Allow",
       "Action": ["rds-db:*"],
       "Resource": ["arn:aws:rds:us-west-2:491947547358:db:${var.db_name}"]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "tf-ecs-instprofile"
  role = "${aws_iam_role.ec2_instance.name}"
}

resource "aws_iam_role" "ec2_instance" {
  name = "tf-ecs-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
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

resource "aws_iam_role_policy" "ec2_instance" {
  name   = "TfEcsInstanceRole"
  role   = "${aws_iam_role.ec2_instance.name}"
  policy = "${data.template_file.instance_profile.rendered}"
}

## ALB

resource "aws_alb_target_group" "appserver" {
  name     = "nginx"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}


resource "aws_alb" "main" {
  name            = "tf-alb-ecs"
  subnets         = ["${aws_subnet.subnet_1.id}", "${aws_subnet.subnet_2.id}"]
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

## CloudWatch Logs

resource "aws_cloudwatch_log_group" "ecs" {
  name = "tf-ecs-group/ecs-agent"
  retention_in_days = 60
}

resource "aws_cloudwatch_log_group" "nginx" {
  name = "tf-ecs-group/server-nginx"
  retention_in_days = 60
}

resource "aws_cloudwatch_log_group" "php" {
  name = "tf-ecs-group/php-app"
  retention_in_days = 60
}


resource "aws_flow_log" "vpc_flow" {
  log_group_name = "vpc-flow/main"
  iam_role_arn   = "${aws_iam_role.vpc_log.arn}"
  vpc_id         = "${aws_vpc.main.id}"
  traffic_type   = "ALL"
}

resource "aws_iam_role" "vpc_log" {
  name = "vpc_log"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_flow_policy" {
  name = "vpc_flow_policy"
  role = "${aws_iam_role.vpc_log.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

## Jump Box

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "jumpbox-sg" {
  name   = "jumpbox-security-group"
  vpc_id = "${aws_vpc.main.id}"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${var.jumpbox_ingress_cidr}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "jumpbox"
  }
}

resource "aws_instance" "jumpbox" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.jumpbox-sg.id}"]
  subnet_id      = "${aws_subnet.subnet_5.id}"

  tags {
    Name = "jumpbox"
  }
}

resource "aws_route_table" "allowedIp" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "${var.jumpbox_ingress_cidr}"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "allowedIp"
  }
}

resource "aws_route_table_association" "e" {
  subnet_id      = "${aws_subnet.subnet_5.id}"
  route_table_id = "${aws_route_table.allowedIp.id}"
}
