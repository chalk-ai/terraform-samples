# Configured per https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md


data aws_caller_identity current {}

locals {
  keda_oidc_provider = trimprefix(var.oidc_url, "https://")
  keda_namespace     = "keda"
}


resource "aws_iam_role" "driver_role" {
  name               = "${var.cluster_name}-ebs-csi-driver-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Effect    = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.keda_oidc_provider}"
        },
        Condition = {
          StringLike = {
            "${local.keda_oidc_provider}:aud" : "sts.amazonaws.com",
            "${local.keda_oidc_provider}:sub" : "system:serviceaccount:kube-system:*"
          }
        }
      },
    ]
  })
}


resource aws_iam_policy encryption_policy {
  name   = "${var.cluster_name}-ebs-csi-encryptionpolicy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource aws_iam_role_policy_attachment encryption_policy_attachment {
  role       = aws_iam_role.driver_role.name
  policy_arn = aws_iam_policy.encryption_policy.arn
}

resource aws_iam_role_policy_attachment managed_policy_attachment {
  role = aws_iam_role.driver_role.name

  # See https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md#set-up-driver-permissions
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}