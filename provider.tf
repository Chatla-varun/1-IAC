terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.13.0"
    }
  }
}

provider "google" {
    region = var.region
    project = var.project-id
    credentials = "creds.json"
}