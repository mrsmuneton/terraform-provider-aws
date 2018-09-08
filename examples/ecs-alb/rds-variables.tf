variable "identifier" {
  default     = "userimages-rds"
  description = "DB Name"
}

variable "storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "engine" {
  default     = "mysql"
  description = "Engine type: mysql"
}

variable "engine_version" {
  description = "Engine version"
  default = "5.7"
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
  default     = ""
  description = "password, provide through your ENV variables"
}
