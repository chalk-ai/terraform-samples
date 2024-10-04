variable "instance_name" {
  type = string
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage" {
  type    = number
  default = 10
}

variable "subnet_ids" {
  type = list(string)
}

variable "engine" {
  type    = string
  default = "postgres"
}

variable "engine_version" {
  type    = string
  default = "15"
}

variable "vpc_id" {
  type = string
}

variable "performance_insights_enabled" {
  type    = bool
  default = false
}


locals {
  admin_username  = "chalk"
  default_db_name = "chalk"

}
variable "override_special" {
  default = "_-#"
}

resource "random_password" "admin_password" {
  length           = 24
  special          = true
  override_special = var.override_special
}

output "username" {
  value = aws_db_instance.main.username
}

output "password" {
  value = aws_db_instance.main.password
}

output "db" {
  value = aws_db_instance.main.db_name
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.instance_name}-subnet-group"
  subnet_ids = var.subnet_ids
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "rds_security_group" {
  name   = "${var.instance_name}-security-group"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  # Allow ingress from anywhere in the vpc
  security_group_id = aws_security_group.rds_security_group.id
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = data.aws_vpc.selected.cidr_block_associations[*].cidr_block
}

resource "aws_security_group_rule" "egress" {
  # Allow egress from anywhere in the vpc
  security_group_id = aws_security_group.rds_security_group.id
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = data.aws_vpc.selected.cidr_block_associations[*].cidr_block
}

resource aws_db_parameter_group main {
  name   = "${var.instance_name}-parameter-group"
  family = "postgres15"

  parameter {
    name         = "shared_preload_libraries"
    value        = "auto_explain,pg_stat_statements,pg_cron"
    apply_method = "pending-reboot"
  }
  parameter {
    name         = "cron.database_name"
    value        = "chalk"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "0"
  }
}

resource "aws_db_instance" "main" {
  publicly_accessible     = false
  backup_retention_period = 7

  skip_final_snapshot       = false
  final_snapshot_identifier = "final-snapshot-${var.instance_name}"

  storage_encrypted = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  identifier             = var.instance_name
  db_name                = local.default_db_name
  username               = local.admin_username
  password               = random_password.admin_password.result
  allocated_storage      = var.allocated_storage
  instance_class         = var.instance_class
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  engine                 = var.engine
  engine_version         = var.engine_version

  performance_insights_enabled = var.performance_insights_enabled
  parameter_group_name         = aws_db_parameter_group.main.name
}

output "address" {
  // address for the database
  value = aws_db_instance.main.address
}

output "port" {
  // address for the database
  value = aws_db_instance.main.port
}

output "engine" {
  value = var.engine
}
