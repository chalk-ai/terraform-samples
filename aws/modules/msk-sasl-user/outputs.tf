output "password" {
  value = random_password.main.result
}

output "secret_id" {
  value = aws_secretsmanager_secret.main.id
  depends_on = [aws_secretsmanager_secret_version.main]
}

output "secret_arn" {
  value = aws_secretsmanager_secret.main.arn
  depends_on = [aws_secretsmanager_secret_version.main]
}

output "username" {
  value = var.username
}