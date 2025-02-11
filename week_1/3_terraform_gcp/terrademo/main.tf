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
  project = "terraform-demo-450422"
  region  = "europe-southwest1"
}

# run terraform init to download the provider
# Next step will be to create a bucket

# Variable in resource has to be globally unique; this means that the bucket name has to be unique across all Google Cloud Storage buckets
# Name of the bucket can be project specific, for example, project name + bucket name or terraform will generate a random name
resource "google_storage_bucket" "demo-bucket" {
  name          = "terraform-demo-450422-terra-bucket"
  location      = "EU"
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