variable "identifier" {
  default     = "userimages-rds"
  description = "Identifier for your DB"
}

variable "storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "engine" {
  default     = "postgres"
  description = "Engine type: postgres"
}

variable "engine_version" {
  description = "Engine version"

  default = {
    postgres = "9.6.8"
  }
}

variable "instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "db_name" {
  default     = "userimages"
  description = "db name"
}

variable "username" {
  default     = "mysqluser"
  description = "User name"
}

variable "password" {
  description = "password, provide through your ENV variables"
}

variable "aws_region" {
  default     = "us-west-2"
  description = "AWS Region"
}
