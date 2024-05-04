variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "oidc_arn" {
  type        = string
  description = "EKS cluster OIDC provider ARN"
}

variable "oidc_url" {
  type        = string
  description = "EKS cluster OIDC url"
}

variable "alb_service_account_name" {
  type        = string
  default     = "aws-load-balancer-controller"
  description = "Name of ALB controller kubernetes service account"
}

variable "alb_service_account_namespace" {
  type        = string
  default     = "kube-system"
  description = "Kube namespace to deploy ALB controller resources into"
}
