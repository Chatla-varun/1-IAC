output "instance_ips" {
    value = {
        for instance in google_compute_instance.tf-instances:
            instance.name => {
                private_ip = instance.network_interface[0].network_ip
                public_ip = instance.network_interface[0].access_config[0].nat_ip
            }
            
    }
}