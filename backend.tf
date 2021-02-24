terraform {
  required_version = ">=0.12.0"
  backend "s3" {
    region  = "ca-central-1"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "coppertree-analytics-terraform-state-bucket"
  }
}
