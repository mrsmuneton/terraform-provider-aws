variable "identifier" {
  default     = "userimages-rds"
  description = "Identifier for your DB"
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

  default = {
    mysql = "5.7"
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
  default     = "Tzl5NgeHPaHMpurPZ"
  description = "password, provide through your ENV variables"
}
