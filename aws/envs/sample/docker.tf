module "workload_image_registry" {
  source = "../../modules/ecr"
  name   = "chalk/${var.account_short_name}_workload_images"
}