variable "aws_region" {
  description = "The AWS region to create ECS and RDS."
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
  default     = "t2.micro"
  description = "AWS instance type"
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
  default     = "1"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
  default     = "4"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
  default     = "2"
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
  description = "php app repository url"
  default = "arn:aws:ecr:us-west-2:491947547358:repository/php-app"
}

variable "php_app_repositiry_uri" {
  description = "php app repository url"
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
  description = "jumpbox ingress"
  default = "75.82.47.204/32"
}
