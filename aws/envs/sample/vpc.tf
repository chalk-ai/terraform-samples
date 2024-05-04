module "vpc" {
  source     = "../../modules/vpc"
  name       = "${var.organization_name}-${var.account_short_name}"

  // These ranges are customizable, but this would work.
  // We recommend a /16 for simplicity.

  cidr_block = "10.90.0.0/16"

  additional_routes = []

  subnets = [
    {
      name              = "primary-a"
      cidr_block        = "10.90.0.0/20"
      public_cidr_block = "10.90.16.0/20"
      az                = "${var.aws_region}a"
    },
    {
      name              = "secondary-a"
      cidr_block        = "10.90.32.0/20"
      public_cidr_block = "10.90.48.0/20"
      az                = "${var.aws_region}}b"
    },
    {
      name              = "tertiary-a"
      cidr_block        = "10.90.64.0/20"
      public_cidr_block = "10.90.80.0/20"
      az                = "${var.aws_region}c"
    },
  ]
}
