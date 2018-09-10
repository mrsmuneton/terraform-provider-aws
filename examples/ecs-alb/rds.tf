variable "name" {
  description = "RDS instance name"
  default = "userimages"
}

variable "engine" {
  description = "Database engine: mysql, postgres, etc."
  default     = "mysql"
}

variable "engine_version" {
  description = "Database version"
  default     = "5.7"
}

variable "port" {
  description = "Port for database to listen on"
  default     = 3306
}

variable "database" {
  description = "The database name for the RDS instance (if not specified, `var.name` will be used)"
  default     = "userimages"
}

variable "username" {
  description = "The username for the RDS instance (if not specified, `var.name` will be used)"
  default     = "mysqluser"
}

variable "password" {
  description = "Mysql user password"
}

variable "multi_az" {
  description = "If true, database will be placed in multiple AZs for HA"
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention, in days"
  default     = 20
}

variable "backup_window" {
  description = "Time window for backups."
  default     = "00:00-01:00"
}

variable "maintenance_window" {
  description = "Time window for maintenance."
  default     = "Mon:01:00-Mon:02:00"
}

variable "monitoring_interval" {
  description = "Seconds between enhanced monitoring metric collection. 0 disables enhanced monitoring."
  default     = "0"
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Required if monitoring_interval > 0."
  default     = ""
}

variable "apply_immediately" {
  description = "If false, apply changes during maintenance window"
  default     = true
}

variable "instance_class" {
  description = "Underlying instance type"
  default     = "db.t2.micro"
}

variable "storage_type" {
  description = "Storage type: standard, gp2, or io1"
  default     = "gp2"
}

variable "allocated_storage" {
  description = "Disk size, in GB"
  default     = 10
}

variable "publicly_accessible" {
  description = "If true, the RDS instance will be open to the internet"
  default     = true
}

variable "ingress_allow_cidr_blocks" {
  description = "A list of CIDR blocks to allow traffic from"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

resource "aws_vpc" "database" {
  cidr_block           = "10.10.128.0/17"
  enable_dns_hostnames = true

  tags {
      Name = "db"
  }
}

resource "aws_internet_gateway" "dbgw" {
  vpc_id = "${aws_vpc.database.id}"
}

resource "aws_route_table" "rds-route-table" {
    vpc_id = "${aws_vpc.database.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.dbgw.id}"
    }

    tags {
        Name = "db route table"
    }
}

resource "aws_route_table_association" "rds-route-table-assoc" {
    count          = "${var.az_count}"
    subnet_id      = "${element(aws_subnet.database.*.id, count.index)}"
    route_table_id = "${aws_route_table.rds-route-table.id}"
}

resource "aws_subnet" "database" {
  count             = "${var.az_count}"
  cidr_block        = "${cidrsubnet(aws_vpc.database.cidr_block, 8, count.index)}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  vpc_id            = "${aws_vpc.database.id}"
}

resource "aws_security_group" "main" {
  name        = "${var.name}-rds"
  description = "Allows traffic to RDS from other security groups"
  vpc_id      = "${aws_vpc.database.id}"

  ingress {
    from_port       = "${var.port}"
    to_port         = "${var.port}"
    protocol        = "TCP"
    security_groups = ["${aws_security_group.rds.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "RDS (${var.name})"
  }
}

resource "aws_db_subnet_group" "database" {
  name        = "${var.name}"
  description = "RDS subnet group"
  subnet_ids  = ["${aws_subnet.database.*.id}"]
}

resource "aws_db_instance" "main" {
  identifier = "${var.name}"

  # Database
  engine         = "${var.engine}"
  engine_version = "${var.engine_version}"
  username       = "${coalesce(var.username, var.name)}"
  password       = "${var.password}"
  multi_az       = "${var.multi_az}"
  name           = "${coalesce(var.database, var.name)}"

  # Backups / maintenance
  backup_retention_period   = "${var.backup_retention_period}"
  backup_window             = "${var.backup_window}"
  maintenance_window        = "${var.maintenance_window}"
  monitoring_interval       = "${var.monitoring_interval}"
  monitoring_role_arn       = "${var.monitoring_role_arn}"
  apply_immediately         = "${var.apply_immediately}"
  final_snapshot_identifier = "${var.name}-finalsnapshot"

  # Hardware
  instance_class    = "${var.instance_class}"
  storage_type      = "${var.storage_type}"
  allocated_storage = "${var.allocated_storage}"

  # Network / security
  db_subnet_group_name   = "${aws_db_subnet_group.database.id}"
  vpc_security_group_ids = ["${aws_security_group.main.id}"]
  publicly_accessible    = "${var.publicly_accessible}"
}

output "db_host" {
  value = "${aws_db_instance.main.address}"
}
