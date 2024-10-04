module "kafka_cluster" {
  source       = "../../modules/msk-cluster"
  cluster_name = "${var.organization_name}-${var.account_short_name}-kafka"
  vpc_id       = module.vpc.id
  subnet_ids   = module.vpc.subnets
  kms_key_id   = aws_kms_key.main.id

  additional_kafka_sasl_secrets = []
  cloudwatch_log_group          = "${var.organization_name}-${var.account_short_name}-kafka-logs"

  instance_type = var.msk_instance_type
}