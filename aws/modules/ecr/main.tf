variable "name" {
  type=string
}

variable "permitted_download_accounts" {
  type=set(string)
  description = "A list of AWS account ids whose principals should be permitted to download *all* images in this repository."
  default = []

  validation {
    condition = length(var.permitted_download_accounts) > 0
    error_message = "At least one account id must be provided."
  }
}

variable "scan_images" {
    type=bool
    description = "Whether to scan images for vulnerabilities."
    default = false
}

resource "aws_ecr_repository" "main" {
  name = var.name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.scan_images
  }
}

resource "aws_ecr_repository_policy" "main" {
  // This policy is fairly permissive, but we typically don't consider
  // images to be particularly sensitive.

  count = length(var.permitted_download_accounts) > 0 ? 1 : 0
  repository = aws_ecr_repository.main.name
  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Sid = "AllowAccountPull"
        Effect = "Allow"
        Principal = {
          AWS = [for k in var.permitted_download_accounts : "arn:aws:iam::${k}:root"]
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken"
        ]
      }
    ]
  })
}

output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}
