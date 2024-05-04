resource "aws_kms_key" "main" {
  description = "Key for ${var.organization_name} ${var.account_short_name}"
}