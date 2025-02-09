terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.19.0"
    }
  }
}

provider "google" {
  project     = "terraform-demo-450422"
  region      = "us-central1"
}