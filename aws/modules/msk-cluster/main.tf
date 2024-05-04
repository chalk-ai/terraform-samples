locals {
  configuration_name     = "${var.cluster_name}-config"
}

module "admin_user" {
  source       = "../msk-sasl-user"
  username     = var.admin_sasl_username
  cluster_name = var.cluster_name
  kms_key_id   = var.kms_key_id
}

resource "aws_msk_scram_secret_association" "kafka_creds" {
  cluster_arn     = aws_msk_cluster.main.arn
  secret_arn_list = concat([module.admin_user.secret_arn], var.additional_kafka_sasl_secrets)
}

resource "aws_msk_configuration" "main" {
  server_properties = <<EOT
auto.create.topics.enable=false
EOT
  kafka_versions    = ["3.4.0"]
  name              = local.configuration_name
}

resource "aws_cloudwatch_log_group" "main" {
  name = var.cloudwatch_log_group
}


resource "aws_msk_cluster" "main" {
  cluster_name           = var.cluster_name
  kafka_version          = "3.4.0"
  number_of_broker_nodes = var.broker_count

  client_authentication {
    sasl {
      scram = true
      iam   = true
    }
  }

  configuration_info {
    arn      = aws_msk_configuration.main.arn
    revision = aws_msk_configuration.main.latest_revision
  }

  broker_node_group_info {
    instance_type   = var.instance_type
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.kafka_security_group.id]

    storage_info {
      ebs_storage_info {
        volume_size = var.ebs_storage_size_gb
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
      in_cluster    = true
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.main.name
      }
    }
  }
}