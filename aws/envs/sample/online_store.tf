# This creates an online store for chalk that can be shared between environments
module "dynamodb_chalk_online_store_table" {
  source         = "../../modules/dynamodb-online-store-table"
  table_name     = "chalk-online-store"
  billing_mode   = "PROVISIONED"
  read_capacity  = 2 # 700k reads/s at 0.5 RCU per item
  write_capacity = 2 # ~200mm/day =~ 2300/s
}
