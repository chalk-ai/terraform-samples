// Configure a DynamoDB table for use as an Online Store
// NOTE: Multiple environments can use the same DynamoDB table

resource "aws_dynamodb_table" "main" {
  name      = var.table_name

  # Key schema
  hash_key  = "__id__"
  range_key = "__ns__"
  attribute {
    name = "__id__"
    type = "S"
  }
  attribute {
    name = "__ns__"
    type = "S"
  }

  deletion_protection_enabled = true
  table_class                 = "STANDARD"

  billing_mode   = var.billing_mode
  write_capacity = var.write_capacity
  read_capacity  = var.read_capacity
}

output "arn" {
  value = aws_dynamodb_table.main.arn
}
output "id" {
  value = aws_dynamodb_table.main.id
}
output "table_name" {
  value = aws_dynamodb_table.main.name
}

output "table_uri" {
  value = format("dynamodb:///%s", aws_dynamodb_table.main.name)
}

output "online_store_kind" {
  value = "DYNAMODB"
}