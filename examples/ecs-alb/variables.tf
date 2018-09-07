variable "aws_region" {
  description = "The AWS region to create ECS and RDS."
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
}

variable "key_name" {
  description = "Name of AWS key pair"
}

variable "instance_type" {
  default     = "t2.micro"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
}

variable "nginx_repository_uri" {
  description = "nginx repository url"
}

variable "nginx_repository_arn" {
  description = "nginx repository url"
}

variable "nginx_tag" {
  description = "nginx image tag"
}

variable "php_app_repository_arn" {
  description = "php app repository url"
}

variable "php_app_repositiry_uri" {
  description = "php app repository url"
}

variable "php_app_tag" {
  description = "php app image tag"
}

variable "bucket_name" {
  description = "S3 bucket name"
}

variable "jumpbox_ingress_cidr" {
  description = "jumpbox ingress"
}
