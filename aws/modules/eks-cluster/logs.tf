resource "aws_cloudwatch_log_group" "cluster-logs" {
  # The log group name format is /aws/eks/<cluster-name>/cluster
  # Reference: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html

  # must match aws_eks_cluster name exactly
  name              = "/aws/eks/${var.name}/cluster"
  retention_in_days = 7
}