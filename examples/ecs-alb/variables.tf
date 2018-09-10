variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-west-2"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "key_name" {
  description = "Name of AWS key pair"
  default="ray.muneton.gofundme.sre"
}

variable "instance_type" {
  default     = "t2.small"
  description = "AWS instance type"
}

variable "desired_task_count" {
  default     = "1"
  description = "Desired task count"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "2"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "6"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "2"
}

variable "admin_cidr_ingress" {
  description = "CIDR to allow tcp/22 ingress to EC2 instance"
  default="75.82.47.204/32"
}

variable "nginx_repository_uri" {
  description = "nginx repository url"
  default = "491947547358.dkr.ecr.us-west-2.amazonaws.com/nginx"
}

variable "nginx_repository_arn" {
  description = "nginx repository url"
  default = "arn:aws:ecr:us-west-2:491947547358:repository/nginx"
}

variable "nginx_tag" {
  description = "nginx image tag"
  default     = "1.10"
}

variable "php_app_repository_arn" {
  description = "nginx repository url"
  default = "arn:aws:ecr:us-west-2:491947547358:repository/php-app"
}


variable "php_app_repositiry_uri" {
  description = "nginx repository url"
  default = "491947547358.dkr.ecr.us-west-2.amazonaws.com/php-app"
}

variable "php_app_tag" {
  description = "php app image tag"
  default     = "7.2.9-fpm"
}

variable "bucket_name" {
  description = "S3 bucket name"
  default     = "userpics-sre-eval"
}

variable "jumpbox_ingress_cidr" {
  description = "Ingress IamInstanceProfileName"
  default     = "75.82.47.204/32"
}
