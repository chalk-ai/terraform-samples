output "username" {
  value = var.admin_sasl_username
}

output "password" {
  value = module.admin_user.password
}

output "secret_id" {
  value = module.admin_user.secret_id
}

output "bootstrap_brokers" {
  value = split(",", aws_msk_cluster.main.bootstrap_brokers_sasl_scram)
}

output "cluster_arn" {
  value = aws_msk_cluster.main.arn
}

output "cluster_name" {
  value = aws_msk_cluster.main.cluster_name
}