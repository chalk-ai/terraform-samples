resource helm_release aws-ebs-csi {
  name = "aws-ebs-csi-driver"
  chart = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  namespace = "kube-system"

  set {
    name="controller.serviceAccount.autoMountServiceAccountToken"
    value=true
  }

  set {
    name="controller.serviceAccount.create"
    value=false
  }
}

#helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
