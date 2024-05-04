
resource kubernetes_service_account driver {
  metadata {
    # Name comes from default helm chart value
    # https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md#installation-1
    name = "ebs-csi-controller-sa"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = "${aws_iam_role.driver_role.arn}"
    }
  }
}