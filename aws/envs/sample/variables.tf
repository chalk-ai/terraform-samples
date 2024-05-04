// General configuration

variable "account_id" {
    type=string
    description = "The AWS account ID that Chalk should be deployed to."

    validation {
        condition = length(var.account_id) == 12 && can(regex("^[0-9]*$", var.account_id))
        error_message = "account_id must be 12 digits / a valid AWS account id"
    }
}

variable "aws_region" {
  type=string
  default="us-east-1"
  description = "The AWS cloud region that Chalk should deploy resources to."
}

variable "organization_name" {
  type = string
  default = "<customer_name>" # edit this
  description = "The name of the organization that Chalk is being deployed for. Should be a short string with no special characters"

  validation {
    condition = length(var.organization_name) <= 10 && length(var.organization_name) > 0 && can(regex("^[a-z0-9]*$", var.organization_name))
    error_message = "organization_name must be 10 characters or less, and contain no special characters"
  }
}

variable "account_short_name" {
  type = string
  default = "prod"
  description = "A short name for the account, used in resource names. Should be a short string with no special characters."

  validation {
    condition = length(var.account_short_name) <= 10 && length(var.account_short_name) > 0 && can(regex("^[a-z0-9]*$", var.account_short_name))
    error_message = "account_short_name must be 10 characters or less"
  }
}

// End general configuration

// Kafka configuration

variable "msk_cluster_name" {
  type = string
  default = null
  description = "The name of the Kafka cluster that Chalk should use."
}

variable "msk_username" {
    type = string
    default = "chalk"
    description = "The username that Chalk should use to connect to the Kafka cluster."
}

variable "msk_password" {
    type = string
    default = "password"
    description = "The password that Chalk should use to connect to the Kafka cluster."
}

variable "msk_instance_type" {
    type = string
    default = "kafka.t3.small" # Unsuitable for production, but typically works for proof-of-concept. Can be changed.
    description = "The instance type that the Kafka cluster should use."
}

// End kafka configuration


// Bucket configuration

variable "temporary_data_retention_days" {
  type = number
  default = 7
}

variable "debug_data_retention_days" {
  type = number
  default = 30
}

variable "dashboard_urls" {
  type = list(string)
  default = ["https://chalk.ai"]
}

// End bucket configuration


locals {
  msk_cluster_name = var.msk_cluster_name != null ? var.msk_cluster_name : "chalk-${var.organization_name}-${var.account_short_name}-msk"
}



// Kubernetes configuration

variable eks_cluster_name {
  type = string
}
