resource aws_secretsmanager_secret "msk_credentials" {
  name = "chalk_msk_credentials"
}

resource aws_secretsmanager_secret_version "msk_credentials" {
  secret_id     = aws_secretsmanager_secret.msk_credentials.id
  secret_string = jsonencode({
    "bootstrap_servers" = module.kafka_cluster.bootstrap_brokers
    "sasl_username"     = var.msk_username
    "sasl_password"     = var.msk_password
  })
}