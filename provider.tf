terraform {

  required_version = "~> 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0.0"
    }
  }

  cloud {
    organization = "lbg-cloud-platform"

    workspaces {
      name = "workspace name here"
    }
  }
}

provider "google" {
  project = var.project_id
}
