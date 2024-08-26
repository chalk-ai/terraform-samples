output oidc-url {
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output oidc-arn {
  value = aws_iam_openid_connect_provider.cluster.arn
}
# End workload federation

output "name" {
  value = aws_eks_cluster.main.name
}

output "endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "ca-base64" {
  value = aws_eks_cluster.main.certificate_authority.0.data
}