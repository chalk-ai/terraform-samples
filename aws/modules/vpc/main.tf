variable "name" {
  type = string
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  type = list(object({ name = string, cidr_block = string, public_cidr_block = string, az = string }))
}

variable "additional_routes" {
  type    = list(object({ name = string, destination_cidr = string, peer_id = string, }))
  default = []
}

variable "additional_private_routes" {
  type    = list(object({ name = string, destination_cidr = string, peer_id = string, }))
  default = []
}

variable tags {
  type = map(string)
  default = {}
}

variable private_subnet_tags {
  type = map(string)
  default = {}
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.name
  }
  enable_dns_hostnames = true
  enable_dns_support   = true
}

variable "igw" { default = false }

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_subnet" "subnet" {
  for_each                = { for index, subnet in var.subnets : subnet.name => subnet }
  cidr_block              = each.value.cidr_block
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge({
    Name = each.value.name
    "kubernetes.io/role/internal-elb" : "1"
  }, var.tags, var.private_subnet_tags)
}


resource "aws_subnet" "public_subnet" {
  for_each = { for index, subnet in var.subnets : subnet.name => subnet }

  vpc_id = aws_vpc.main.id

  availability_zone       = each.value.az
  cidr_block              = each.value.public_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "${each.value.name}-public"
    "kubernetes.io/role/elb" : "1"
  }
}


resource "aws_eip" "main" {
  for_each = { for index, subnet in var.subnets : subnet.name => subnet }
}

resource "aws_nat_gateway" "nat_gateway" {
  for_each = { for index, subnet in var.subnets : subnet.name => subnet }

  allocation_id     = aws_eip.main[each.key].id
  subnet_id         = aws_subnet.public_subnet[each.key].id
  connectivity_type = "public"
}

resource "aws_route_table" "main" {
  for_each = { for index, subnet in var.subnets : subnet.name => subnet }

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[each.key].id
  }

  dynamic "route" {
    for_each = concat(var.additional_routes, var.additional_private_routes)
    content {
      cidr_block                = route.value.destination_cidr
      vpc_peering_connection_id = route.value.peer_id
    }
  }


  tags = {
    Manager  = "terraform"
    Category = "private"
  }
}

resource "aws_route_table" "public_route_table" {
  for_each = { for index, subnet in var.subnets : subnet.name => subnet }

  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  dynamic "route" {
    for_each = var.additional_routes
    content {
      cidr_block                = route.value.destination_cidr
      vpc_peering_connection_id = route.value.peer_id
    }
  }
}

resource "aws_route_table_association" "main" {
  for_each       = { for index, subnet in var.subnets : subnet.name => subnet }
  route_table_id = aws_route_table.main[each.key].id
  subnet_id      = aws_subnet.subnet[each.value.name].id
}

resource "aws_route_table_association" "main-public" {
  for_each       = { for index, subnet in var.subnets : subnet.name => subnet }
  route_table_id = aws_route_table.public_route_table[each.key].id
  subnet_id      = aws_subnet.public_subnet[each.value.name].id
}


resource "aws_flow_log" "main" {
  iam_role_arn    = aws_iam_role.flow_log_writer.arn
  log_destination = aws_cloudwatch_log_group.vpc_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id
}

resource "aws_cloudwatch_log_group" "vpc_log_group" {
  name              = "${var.name}_management_vpc_logs"
  retention_in_days = 365
}

resource "aws_iam_role" "flow_log_writer" {
  name = "${var.name}_flow_log_writer"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpc_log_policy" {
  name = "flow_log_writer_role_policy"
  role = aws_iam_role.flow_log_writer.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
POLICY
}

output "flow_log_writer_arn" {
  value = aws_iam_role.flow_log_writer.arn
}

output "id" {
  value = aws_vpc.main.id
}

output "subnets" {
  value = [for i, sn in var.subnets : aws_subnet.subnet[sn.name].id]
}

output "public_subnets" {
  value = [for i, sn in var.subnets : aws_subnet.public_subnet[sn.name].id]
}

output "nat_public_ips" {
  value = [for i, sn in var.subnets : aws_eip.main[sn.name].public_ip]
}

output "cidr_block" {
  value = aws_vpc.main.cidr_block
}
