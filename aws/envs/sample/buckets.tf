

// This bucket stores .tar.gz files that contain your source code.
// Typically order of a few gigabytes; we recommend no expiration policy, but 
// if you set one, perhaps a year.
resource "aws_s3_bucket" "source" {
  bucket = "${var.organization_name}-chalk-${var.account_short_name}-source"
}


// This is used for offline store data transfer and other
// temporary data transfer; should have an expiration policy
resource "aws_s3_bucket" "data-transfer" {
  bucket = "${var.organization_name}}-chalk-${var.account_short_name}-data-transfer"
}


// this is the bucket that stores long-lived datasets. typically should never be deleted
// unless for compliance reasons.
resource "aws_s3_bucket" "datasets" {
  bucket = "${var.organization_name}}-chalk-${var.account_short_name}-query-dataset"
}

// this bucket stores intermediate plan data and plan metadata. we recommend retaining
// for 30 days. low data volume, very useful for support & user debugging.
resource "aws_s3_bucket" "debug" {
  bucket = "${var.organization_name}-chalk-${var.account_short_name}-debug"
}


// delete bulk insert files after 7 days
resource "aws_s3_bucket_lifecycle_configuration" "data-transfer-lifecycle-config" {
  bucket = aws_s3_bucket.data-transfer.id

  rule {
    status = "Enabled"
    id     = "expire-bulk-inserts"

    expiration {
      days = local.temporary_data_retention_days
    }
  }
}

// delete debug information files after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "debug-lifecycle-config" {
  bucket = aws_s3_bucket.debug.id

  rule {
    status = "Enabled"
    id     = "expire-debug-data"

    expiration {
      days = local.debug_data_retention_days
    }
  }
}

// allow the web UI to pull from the source bucket
resource "aws_s3_bucket_cors_configuration" "source_cors_config" {
  bucket = aws_s3_bucket.source.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = local.dashboard_urls
  }
}
