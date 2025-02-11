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
