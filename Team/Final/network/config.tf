terraform {
  backend "s3" {
    bucket = "team-final-project"        // Bucket where to SAVE Terraform State
    key    = "Network/terraform.tfstate" // Object name in the bucket to SAVE Terraform State
    region = "us-east-1"                 // Region where bucket is created
  }
}