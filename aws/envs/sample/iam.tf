variable "management_role_name" {
  default = "chalk-management-role"
}

variable "background_persistence_role_name" {
  default = "chalk-background-persistence"
}

resource "aws_iam_role" "management_role" {
  name               = var.management_role_name
  description        = "Management role used by Chalk's API server to manage Chalk resources."
  assume_role_policy = jsonencode()
}

resource "aws_iam_role" "workload_role" {
  name        = ""
  description = "Role used for kubernetes service account that your feature engineering workloads run as."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.oidc-arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${trimprefix(var.oidc-url, "https://")}:sub" : "system:serviceaccount:${local.ns-str}:${local.service_account_name}",
            "${trimprefix(var.oidc-url, "https://")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "workload_policy" {
  role   = aws_iam_role.workload_role.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:*", // pull the source code and access datasets
          "dynamodb:*", // Used for dynamodb online store
          "secretsmanager:*", // pull secrets inside the engine
          "sts:AssumeRole", // pull secrets inside the engine
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "persistence_role" {
  name        = var.background_persistence_role_name
  description = "Role used for kubernetes service account that performs background background persistence tasks."

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.oidc_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${trimprefix(var.oidc_url, "https://")}:sub" : "system:serviceaccount:${var.background_persistence_namespace}:${local.service_account_name}",
            "${trimprefix(var.oidc_url, "https://")}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "default" {
  role   = aws_iam_role.persistence_role.name
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "s3:*", // pull/upload parquet files from/to s3
          "dynamodb:*", // Used if customer has a DynamoDB online store.
          "secretsmanager:*", // load any secrets from the secret manager
          "kms:GenerateDataKey" // used for CMEK to upload files to redshift, really just need the data transfer bucket
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}