

output "chalk_environment_configuration" {
  value = {

    // general
    aws_account_id = var.account_id
    aws_region = var.aws_region

    // eks
    eks_cluster_name = var.eks_cluster_name

    // kubernetes
    k8s_background_persistence_namespace = ""
    k8s_background_persistence_service_account_name = ""

    k8s_environments = {
      "dev" = {
        namespace = "dev"
        service_account_name = "env-dev-workload-identity"
      }
      "prod" = {
        namespace = "prod"
        service_account_name = "env-prod-workload-identity"
      }
    }

    // docker
    ecr_registry = module.workload_image_registry.repository_url

    // k8s cloudwatch log group
    cloudwatch_log_group = "/aws/eks/${var.eks_cluster_name}/cluster"

    // buckets
    source_bucket_arn = aws_s3_bucket.source.arn
    data_transfer_bucket_arn = aws_s3_bucket.data-transfer.arn
    dataset_bucket_arn = aws_s3_bucket.datasets.arn
    debug_bucket_arn = aws_s3_bucket.debug.arn

    // Assumed to contain boostrap broker, sasl username, sasl password

    kafka = {
      kafka_credentials_secret_arn = aws_secretsmanager_secret.kafka_credentials.arn
      cluster_arn = module.kafka_cluster.cluster_arn
    }

    // optional
    secret_manager_config = {
      # secret_kms_arn = ""

      # secret_tags = {
      #   "ManagedBy" : "CHALK"
      # }

      # secret_prefix = "CHALK_"
    }

    // vpc
    vpc_id = module.vpc.id
    private_subnets = module.vpc.subnets
    cidr_range = module.vpc.cidr_block

  }
}