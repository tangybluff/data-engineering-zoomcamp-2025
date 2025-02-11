terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.19.0"
    }
  }
}

provider "google" {
    credentials = "./keys/my-creds.json"
  project = "terraform-demo-450422"
  region  = "europe-southwest1"
}
