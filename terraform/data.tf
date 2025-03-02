data "oci_identity_compartment" "this" {
  id = var.compartment_ocid
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.tenancy_ocid
}

resource "random_password" "k3s_token" {
  length  = 64
  special = false
}

data "cloudinit_config" "k3s_tpl" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/k3s-install.sh", {
      k3s_version                       = var.k3s_version,
      k3s_token                         = random_password.k3s_token.result,
      compartment_ocid                  = var.compartment_ocid,
      first_instance_id                 = "${var.cluster_name}-control-plane-0",
      k3s_url                           = oci_network_load_balancer_network_load_balancer.network_load_balancer.ip_addresses[0].ip_address,
      oci_ccm_version                   = var.oci_ccm_version,
      external_snapshotter_version      = var.external_snapshotter_version,
      oci_config_ini                    = base64encode(local.oci_config_ini),
      oci_cloud_provider_config         = base64encode(local.oci_cloud_provider_config),
      oci_volume_provisioner_config     = base64encode(local.oci_volume_provisioner_config),
    })
  }
}