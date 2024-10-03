module "rds" {
  source                       = "../../modules/rds"
  instance_name                = "${var.organization_name}-metadata-rds"
  alert_topic_arn              = ""
  vpc_id                       = module.vpc.id
  subnet_ids                   = module.vpc.subnets
  instance_class               = "db.t3.medium"
  allocated_storage            = 50
  performance_insights_enabled = true
}