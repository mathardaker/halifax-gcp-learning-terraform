resource "google_compute_instance" "windows_vm" {
  name         = "my-windows-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-m"

  shielded_instance_config {
    enable_secure_boot = true
  }

  boot_disk {
    initialize_params {
      image = "windows-cloud/windows-2019"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.windows_subnet.name
    access_config {
      // creates ephemeral public IP
    }
  }
}
