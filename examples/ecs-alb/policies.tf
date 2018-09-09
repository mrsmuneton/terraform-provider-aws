
resource "aws_iam_role_policy" "ec2_instance" {
  name   = "TfEcsInstanceRole"
  role   = "${aws_iam_role.ec2_instance.name}"
  policy = "${data.template_file.instance_profile.rendered}"
}
