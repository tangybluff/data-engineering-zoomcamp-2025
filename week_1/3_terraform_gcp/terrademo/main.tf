# Terraform file to create a Google Cloud Storage bucket

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.19.0"
    }
  }
}

# export GOOGLE_CREDENTIALS="path/to/your/credentials.json"
# echo $GOOGLE_CREDENTIALS
provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}

# run terraform init to download the provider
# Next step will be to create a bucket

# Variable in resource has to be globally unique; this means that the bucket name has to be unique across all Google Cloud Storage buckets
# Name of the bucket can be project specific, for example, project name + bucket name or terraform will generate a random name
resource "google_storage_bucket" "demo-bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

# terraform plan to see the changes
# terraform apply to apply the changes

# Part B
resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id = var.bq_dataset_name
  location   = var.location
}

# terraform fmt to format the file
# terraform plan to see the changes