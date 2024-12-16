#Creating the VPC Network
resource "google_compute_network" "tf-vpc" {
    name = var.vpc-name
    auto_create_subnetworks = false 

}


# #Creating the subnetwork

resource "google_compute_subnetwork" "tf-subnet" {
  name = "${var.vpc-name}-subnet"
  network = google_compute_network.tf-vpc.id
  region = var.region
  ip_cidr_range = var.cidr-range
}


# #Creating the firewallrules to allow the inbound traffic

resource "google_compute_firewall" "tf-firewall" {
  name = var.firewall-name
  network = google_compute_network.tf-vpc.id
  dynamic "allow" {
    for_each = var.allowed-ports
    content {
      protocol = "tcp"
      ports    = [allow.value]
    }
    
  }
  source_ranges = var.source-range
  
}

resource "google_compute_instance" "tf-instances" {
  for_each = var.vm-instances
  name = each.key
  zone = each.value["zone"]
  machine_type = each.value.type
  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20241115"
      size  = 10
      type  = "pd-balanced"
    }

  }
  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    subnetwork  = google_compute_subnetwork.tf-subnet.id
    network = google_compute_network.tf-vpc.id
  }

}