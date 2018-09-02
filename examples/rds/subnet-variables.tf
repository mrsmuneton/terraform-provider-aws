variable "subnet_1_cidr" {
  default     = "10.10.2.0/24"
  description = "Your AZ"
}

variable "subnet_2_cidr" {
  default     = "10.10.3.0/24"
  description = "Your AZ"
}

variable "az_1" {
  default     = "us-west-2a"
  description = "Your Az1, use AWS CLI to find your account specific"
}

variable "az_2" {
  default     = "us-west-2b"
  description = "Your Az2, use AWS CLI to find your account specific"
}

variable "vpc_id" {
  default     = "vpc-0c7170004e2a8b542"
  description = "Your VPC ID"
}
