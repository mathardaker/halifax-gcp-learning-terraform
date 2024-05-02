resource "google_compute_instance" "linux_vm" {
  name         = "my-linux-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  shielded_instance_config {
    enable_secure_boot = true
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.linux_subnet.name
    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "testUser:YOUR SSH KEY HERE"
  }
}
