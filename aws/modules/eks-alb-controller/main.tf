locals {
  alb_service_account_name      = var.alb_service_account_name
  alb_service_account_namespace = var.alb_service_account_namespace
}

resource "kubernetes_service_account" "alb" {
  metadata {
    name      = local.alb_service_account_name
    namespace = local.alb_service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb.arn
    }
  }
}

resource "helm_release" "alb" {
  name            = "aws-load-balancer-controller"
  repository      = "https://aws.github.io/eks-charts"
  chart           = "aws-load-balancer-controller"
  namespace       = local.alb_service_account_namespace
  cleanup_on_fail = true
  atomic          = true
  wait_for_jobs   = true

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb.metadata[0].name
  }
}