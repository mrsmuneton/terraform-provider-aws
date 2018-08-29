output "instance_security_group" {
  value = "${aws_security_group.instance_sg.id}"
}

output "launch_configuration" {
  value = "${aws_launch_configuration.nginx.id}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.nginx.id}"
}

output "elb_hostname" {
  value = "${aws_alb.main.dns_name}"
}
