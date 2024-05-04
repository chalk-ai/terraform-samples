resource "random_password" "main" {
  length  = 50
  special = false
}

resource "aws_secretsmanager_secret" "main" {
  name       = "AmazonMSK_kafka_${var.cluster_name}_${var.username}"
  kms_key_id = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "main" {
  secret_id = aws_secretsmanager_secret.main.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.main.result
  })
}

