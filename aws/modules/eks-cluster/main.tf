resource "aws_eks_cluster" "main" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn

  version = var.kubernetes_version

  # upgrade_policy works with latest hashicorp/aws provider as of writing, 5.63.1
  upgrade_policy {
    support_type = "STANDARD"
  }

  enabled_cluster_log_types = var.log_types

  vpc_config {
    subnet_ids = var.subnets
    endpoint_public_access = var.enable_public_access
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  #  depends_on = [
  #  ]

  depends_on = [
    aws_cloudwatch_log_group.cluster-logs,

    #    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    #    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}

output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}


data "aws_caller_identity" "current" {}