output "node_ips" {
  value = [for instance in oci_core_instance.node : instance.public_ip]
}

output "load_balancer_ip" {
  value = oci_network_load_balancer_network_load_balancer.network_load_balancer.ip_addresses[0].ip_address
}

output "oci_cloud_provider_config" {
  value     = local.oci_cloud_provider_config
  sensitive = true
}
