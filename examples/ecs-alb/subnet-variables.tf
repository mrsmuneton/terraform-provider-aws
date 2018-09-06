variable "subnet_1_cidr" {
  default     = "10.10.160.0/20"
  description = "Subnet Cidr"
}

variable "subnet_2_cidr" {
  default     = "10.10.176.0/20"
  description = "Subnet Cidr"
}

variable "subnet_3_cidr" {
  default     = "10.10.192.0/20"
  description = "Subnet Cidr"
}

variable "subnet_4_cidr" {
  default     = "10.10.208.0/20"
  description = "Subnet Cidr"
}

variable "subnet_5_cidr" {
  default     = "10.10.240.0/20"
  description = "Subnet Cidr"
}

variable "az_1" {
  default     = "us-west-2a"
  description = "Your Az1, use AWS CLI to find your account specific"
}

variable "az_2" {
  default     = "us-west-2b"
  description = "Your Az2, use AWS CLI to find your account specific"
}
