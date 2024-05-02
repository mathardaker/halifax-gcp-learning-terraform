terraform {
  required_providers {
    google = {
      version = "~> 3.83.0"
    }
  }

  cloud {
    organization = "lbg-cloud-platform"

    workspaces {
      name = "YOUR WORKSPACE HERE"
    }
  }
}

provider "google" {
  project = var.project
}
