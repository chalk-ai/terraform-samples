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

locals {
  # i.e. your company name, but in a format suitable for an s3 bucket name component





}
