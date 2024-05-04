resource "aws_security_group" "kafka_security_group" {
  name        = "kafka-${var.cluster_name}"
  description = "Security group for kafka"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "allow_self_ingress" {
  type              = "ingress"
  self              = true
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.kafka_security_group.id
}

resource "aws_security_group_rule" "allow_vpc_ingress" {
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.kafka_security_group.id
}


resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.kafka_security_group.id
}