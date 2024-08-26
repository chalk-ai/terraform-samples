variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "eks_cluster_endpoint" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "rule_name_prefix" {
  description = "Prefix used for all event bridge rules"
  type        = string
  default     = "Karpenter"
}

variable "karpenter_iam_role_name" {
  type = string
}

variable "node_role_name" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "termination_queue_name" {
  type = string
}

variable enable_karpenter_instance_profile_creation {
  type = bool
  # should
}

variable "enable_spot_termination" {
  type    = bool
  default = true
}

variable subnet_selector_terms {
  type    = list(object({id = optional(string), tags = optional(map(string))}))
  default = null
  nullable=true
}