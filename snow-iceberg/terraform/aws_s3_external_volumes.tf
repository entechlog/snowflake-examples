# S3 bucket for External Volumes
module "external_volume_bucket" {
  source         = "github.com/entechlog/aws-examples//aws-modules/s3"
  s3_bucket_name = ["raw-ext-volume"]
  use_env_code   = var.use_env_code
}