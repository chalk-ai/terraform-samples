terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0.0"
    }
    helm = {

    }
    kubernetes = {

    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">=2"
    }
  }
}


variable "sa-prefix" {
  type    = string
  default = ""
  validation {
    # must end in a hyphen or be empty
    condition     = can(regex("^.*-$", var.sa-prefix)) || var.sa-prefix == ""
    error_message = "sa-prefix must end in a hyphen or be empty"
  }
}


variable "max_cpu" {
  type    = number
  default = 128000
}

variable "min_instance_generation" {
  type    = string
  default = null
}

variable "create_default_karpenter_nodepool" {
  type    = bool
  default = true
}

variable "default_nodepool_consolidation_policy" {
  type    = string
  default = "WhenUnderutilized"
}

variable "node_classes" {
  type = map(object({
    subnets = optional(list(string))
  }))
  default = {}
}

variable "node_pools" {
  type = map(object({
    cpu_limit               = number
    instance_categories     = optional(list(string))
    instance_families       = optional(list(string))
    instance_cpus           = optional(list(string))
    instance_types          = optional(list(string))
    min_instance_generation = optional(string)
    node_class              = string
    node_labels             = map(string)
    node_annotations        = map(string)
    node_taints             = optional(list(map(string)))
    consolidation_policy    = optional(string)
    weight                  = optional(number)
  }))
  default = {}
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}


locals {
  name            = "karpenter-${var.cluster_name}"
  cluster_version = data.aws_eks_cluster.cluster.version

  default_pool_min_instance_generation = var.min_instance_generation != null ? var.min_instance_generation : 6

  node_role_name = var.node_role_name

  tags = {}
}


resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  #  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  #  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart   = "karpenter"
  version = "v0.33.0"

  # from settings: interruptionQueueName: ${module.karpenter.queue_name}

  values = [
    <<-EOT
    settings:
      clusterName: ${var.cluster_name}
      clusterEndpoint: ${var.eks_cluster_endpoint}

    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${aws_iam_role.irsa[0].arn}
    EOT
  ]
}

locals {
  subnet_selector_terms = var.subnet_selector_terms == null ? tolist([
    {
      id : null,
      tags : tomap({
        "karpenter.sh/discovery" : var.cluster_name
      })
    }
  ]) : var.subnet_selector_terms
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = yamlencode({
    apiVersion : "karpenter.k8s.aws/v1beta1"
    kind : "EC2NodeClass"
    metadata : {
      name : "default"
    }
    spec : {
      amiFamily : "AL2"
      role : local.node_role_name
      subnetSelectorTerms : local.subnet_selector_terms
      blockDeviceMappings : [
        {
          deviceName : "/dev/xvda",
          ebs : {
            volumeType : "gp3"
            volumeSize : "50Gi"
            deleteOnTermination : true
          }
        }
      ]
      securityGroupSelectorTerms : [
        {
          tags : {
            "karpenter.sh/discovery" : var.cluster_name
          }
        },
        {
          tags : {
            "aws:eks:cluster-name" : var.cluster_name
          }
        }
      ]
      tags : {
        "karpenter.sh/discovery" : var.cluster_name
      }
    }
  })
  wait             = true
  wait_for_rollout = true

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "additional_node_classes" {
  for_each = var.node_classes

  yaml_body = yamlencode({
    apiVersion : "karpenter.k8s.aws/v1beta1"
    kind : "EC2NodeClass"
    metadata : {
      name : each.key
    }
    spec : {
      amiFamily : "AL2"
      role : local.node_role_name
      subnetSelectorTerms : [
        for subnet in each.value.subnets :
        {
          id : subnet
        }
      ]
      securityGroupSelectorTerms : [
        {
          tags : {
            "karpenter.sh/discovery" : var.cluster_name
          }
        },
        {
          tags : {
            "aws:eks:cluster-name" : var.cluster_name
          }
        }
      ]
      tags : {
        "karpenter.sh/discovery" : var.cluster_name
      }
    }
  })

  depends_on = [
    helm_release.karpenter
  ]

}

resource "kubectl_manifest" "karpenter_node_pool" {
  count = var.create_default_karpenter_nodepool ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["m", "r", "c"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["8", "16", "32", "36", "48", "64", "72", "96"]
            - key: "karpenter.k8s.aws/instance-hypervisor"
              operator: In
              values: ["nitro"]
            - key: "kubernetes.io/arch"
              operator: In
              values: ["amd64"]
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["${local.default_pool_min_instance_generation}"]
            - key: "karpenter.sh/capacity-type"
              operator: In
              values: ["on-demand"]
      limits:
        cpu: ${var.max_cpu}
      disruption:
        consolidateAfter: ${var.default_nodepool_consolidation_policy == "WhenEmpty" ? "1h" : "null"}
        consolidationPolicy: ${var.default_nodepool_consolidation_policy}
        expireAfter: 720h
      weight: 1
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}

resource "kubectl_manifest" "additional_pool" {
  for_each = var.node_pools

  yaml_body = yamlencode({
    apiVersion : "karpenter.sh/v1beta1"
    kind : "NodePool"
    metadata : {
      name : each.key
    },
    spec : {
      template : {
        metadata : {
          labels : each.value.node_labels
          annotations : each.value.node_annotations
        }
        spec : {
          nodeClassRef : {
            name : each.value.node_class
          }
          taints : each.value.node_taints != null ? each.value.node_taints : []
          requirements : flatten([
              each.value.instance_categories != null ? [
              {
                key : "karpenter.k8s.aws/instance-category"
                operator : "In"
                values : each.value.instance_categories
              }
            ] : [],
              each.value.instance_cpus != null ? [
              {
                key : "karpenter.k8s.aws/instance-cpu"
                operator : "In"
                values : each.value.instance_cpus
              }
            ] : [],
              each.value.instance_families != null ? [
              {
                key : "karpenter.k8s.aws/instance-family"
                operator : "In"
                values : each.value.instance_families
              }
            ] : [],
              each.value.instance_types != null ? [
              {
                key : "node.kubernetes.io/instance-type"
                operator : "In"
                values : each.value.instance_types
              }
            ] : [],
            {
              key : "karpenter.k8s.aws/instance-hypervisor"
              operator : "In"
              values : [
                "nitro"
              ]
            },
            {
              key : "kubernetes.io/arch"
              operator : "In"
              values : [
                "amd64"
              ]
            },
              each.value.min_instance_generation != null ? [
              {
                key : "karpenter.k8s.aws/instance-generation"
                operator : "Gt"
                values : [
                  "${each.value.min_instance_generation}"
                ]
              }
            ] : [],
            {
              key : "karpenter.sh/capacity-type"
              operator : "In"
              values : [
                "on-demand"
              ]
            }
          ])
        }
      }
      limits : {
        cpu : each.value.cpu_limit
      }
      disruption : each.value.consolidation_policy == null ? {
        consolidationPolicy : "WhenUnderutilized"
        consolidateAfter : null
        expireAfter : "720h"
      } : each.value.consolidation_policy == "WhenEmpty" ? {
        consolidationPolicy : "WhenEmpty"
        consolidateAfter : "1h"
        expireAfter : "720h"
      } : {
        consolidationPolicy : "WhenUnderutilized"
        consolidateAfter : null
        expireAfter : "720h"
      }
      weight : each.value.weight == null ? 2 : each.value.weight
    }
  })
  depends_on = [
    kubectl_manifest.karpenter_node_class,
    kubectl_manifest.additional_node_classes,
  ]
}


# Example deployment using the [pause image](https://www.ianlewis.org/en/almighty-pause-container)
# and starts with zero replicas
