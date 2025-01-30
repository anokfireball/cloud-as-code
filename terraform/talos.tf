resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
        }
      }
    }
  )
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = oci_network_load_balancer_network_load_balancer.network_load_balancer.ip_addresses[0].ip_address
  endpoint             = oci_network_load_balancer_network_load_balancer.network_load_balancer.ip_addresses[0].ip_address
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each                    = { for idx, val in oci_core_instance.controlplane : idx => val }
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.public_ip

  config_patches = [
    yamlencode({
      machine = {
        kubelet = {
          extraArgs = {
            "provider-id" = each.value.id
          }
        }
      }
    })
  ]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoint             = [for k, v in oci_core_instance.controlplane : v.public_ip][0]
  node                 = [for k, v in oci_core_instance.controlplane : v.public_ip][0]

  lifecycle {
    ignore_changes = all
  }
}
