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
      image = data.google_compute_image.tf-machine-image.self_link
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

# This connection block is help us to connect to vm
  connection {
    type = "ssh" # linux
    user = var.vm-user  #amazon ubuntu #redhat ec2-user
    host = self.network_interface[0].access_config[0].nat_ip
    #We need to private key connect but before that public should be available #lets create keys dynamically or manually
    private_key = tls_private_key.tf-sshkey.private_key_pem
  }

  metadata = {
    ssh-keys = "${var.vm-user}:${tls_private_key.tf-sshkey.public_key_openssh}"
  }

  #Provisioners(file local, remote) to here we are using file to copy ansible.sh to ansible machine

  provisioner "file" {
    source = each.key == "ansible" ? "ansible.sh" : "other.sh"
    destination = each.key == "ansible" ? "/home/${var.vm-user}/ansible.sh": "/home/${var.vm-user}/other.sh"
  }

  provisioner "remote-exec" {
    inline = [ 
      each.key == "ansible" ? "chmod +x /home/${var.vm-user}/ansible.sh && sh /home/${var.vm-user}/ansible.sh" : "echo 'skipping the command'"
     ]
  }
}

# Generation of RSA key dynamically of size 4096 bits for vm access 
resource "tls_private_key" "tf-sshkey" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "tf-private_key" {
  content  = tls_private_key.tf-sshkey.private_key_pem
  filename = "${path.module}/id_rsa"
}

resource "local_file" "tf-public_key" {
  content  = tls_private_key.tf-sshkey.public_key_openssh
  filename = "${path.module}/id_rsa.pub"
}

data "google_compute_image" "tf-machine-image" {
  project = "ubuntu-os-cloud"
  family = "ubuntu-2404-lts-amd64"
}