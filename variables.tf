variable "vpc-name" {
    default = "ecommerce-vpc"
}

variable "region" {
  default = "us-east1"
}

variable "project-id" {
  default = "stoked-virtue-440907-h8"
}

variable "cidr-range" {
  default = "10.2.0.0/16"
}

variable "firewall-name" {
  default = "allow-ports"
}

variable "allowed-ports" {
  default = ["80","8080","8081","9000","22"]
}

variable "source-range" {
  default = ["0.0.0.0/0"]
}