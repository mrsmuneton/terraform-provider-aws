
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = "10.10.0.0/17"

  tags {
      Name = "main"
  }
}

resource "aws_subnet" "public" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.main.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}
### Compute

resource "aws_autoscaling_group" "asg" {
  name                 = "tf-asg"
  vpc_zone_identifier  = ["${aws_subnet.public.*.id}"]
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.lc.name}"
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

# resource "aws_instance" "jumpbox" {
#   ami           = "${data.aws_ami.ubuntu.id}"
#   instance_type = "t2.micro"
#   associate_public_ip_address = true
#   key_name               = "${var.key_name}"
#   vpc_security_group_ids = ["${aws_security_group.jumpbox-sg.id}"]
#   subnet_id      = "${element(aws_subnet.public.*.id, 1)}"
#
#   tags {
#     Name = "jumpbox"
#   }
# }


# resource "aws_flow_log" "vpc_flow" {
#   log_group_name = "vpc-flow/main"
#   iam_role_arn   = "${aws_iam_role.vpc_log.arn}"
#   vpc_id         = "${aws_vpc.main.id}"
#   traffic_type   = "ALL"
# }
