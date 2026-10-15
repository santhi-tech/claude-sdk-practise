terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Ubuntu 24.04 ships Python 3.12, matching .python-version.
resource "google_compute_instance" "dev" {
  name         = "claude-sdk-dev"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      size  = 30
    }
  }

  network_interface {
    network = "default"
    access_config {} # external IP so the startup script can reach the web
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail

    apt-get update -y
    apt-get install -y python3 python3-venv python3-pip curl ca-certificates

    # Node.js 22 LTS via NodeSource (web download)
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
    apt-get install -y nodejs

    # Docker Engine via get.docker.com (web download)
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
  EOT
}

output "instance_ip" {
  value = google_compute_instance.dev.network_interface[0].access_config[0].nat_ip
}
