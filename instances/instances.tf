// Ubuntu 16.04 AMI
data "google_compute_image" "my_image" {
  family  = "debian-9"
  project = "debian-cloud"
}

// Bastion Host
resource "google_compute_instance" "bastion" {
  count                   = 1
  name                    = "vm-bastion"
  machine_type            = "f1-micro"
  metadata_startup_script = templatefile("${path.module}/userdata-scripts/ubuntu-bastion-userdata-sftd.sh", { sftd_version = var.sftd_version, enrollment_token = var.enrollment_token })
  zone                    = var.gcp_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
    }
  }

  tags = ["bastion"]

  metadata = {
    Name        = var.name
    Environment = var.environment
    terraform   = true
  }
  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
}

// Target Instances
resource "google_compute_instance" "target" {
  count                   = var.instances
  name                    = "vm-target"
  machine_type            = "f1-micro"
  metadata_startup_script = templatefile("${path.module}/userdata-scripts/ubuntu-userdata-sftd.sh", { sftd_version = var.sftd_version, enrollment_token = var.enrollment_token, instance = count.index })
  zone                    = var.gcp_zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
    }
  }

  metadata = {
    Name        = var.name,
    Environment = var.environment,
    terraform   = true
  }
  network_interface {
    network = var.network

    access_config {
      // Ephemeral IP
    }
  }
}
