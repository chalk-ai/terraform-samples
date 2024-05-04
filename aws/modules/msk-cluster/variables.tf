variable "cluster_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "broker_count" {
  type    = number
  default = 3
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ebs_storage_size_gb" {
  type = number
  default = 200
  description = "The size of the EBS volume used by each broker in GB"
}


variable "kms_key_id" {
  type     = string
  nullable = true
}

variable "cloudwatch_log_group" {
  type = string
}

variable "admin_sasl_username" {
  type    = string
  default = "admin"
}

variable "additional_kafka_sasl_secrets" {
  type        = list(string)
  description = "Additional aws secretmanager secret ids that should be associated with the cluster. Can be used to permit additional users."
}