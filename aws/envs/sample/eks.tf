module "eks" {
  source  = "../../modules/eks-cluster"
  name    = "${var.organization_name}-${var.account_short_name}-eks"
  subnets = module.vpc.subnets
}