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