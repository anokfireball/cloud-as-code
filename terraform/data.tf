data "oci_identity_compartment" "this" {
  id = var.compartment_ocid
}

data "oci_identity_availability_domains" "availability_domains" {
  #Required
  compartment_id = var.tenancy_ocid
}

data "oci_core_image_shapes" "image_shapes" {
  depends_on = [oci_core_shape_management.image_shape]
  #Required
  image_id = oci_core_image.talos_image.id
}

data "talos_image_factory_extensions_versions" "this" {
  # get the latest talos version
  talos_version = var.talos_version
  filters = {
    names = var.talos_extensions
  }
}

data "talos_image_factory_urls" "this" {
  talos_version = var.talos_version
  schematic_id  = talos_image_factory_schematic.this.id
  platform      = "oracle"
  architecture  = var.architecture
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [for k, v in oci_core_instance.controlplane : v.public_ip]
  nodes                = [for k, v in oci_core_instance.controlplane : v.public_ip]
}

data "talos_machine_configuration" "controlplane" {
  cluster_name = var.cluster_name
  cluster_endpoint = "https://${oci_network_load_balancer_network_load_balancer.network_load_balancer.ip_addresses[0].ip_address}:6443"

  machine_type    = "controlplane"
  machine_secrets = talos_machine_secrets.machine_secrets.machine_secrets

  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  docs     = false
  examples = false

  config_patches = [
    local.talos_base_configuration,
    <<-EOT
    machine:
      nodeLabels:
        node.kubernetes.io/exclude-from-external-load-balancers:
          $patch: delete
      features:
        kubernetesTalosAPIAccess:
          enabled: true
          allowedRoles:
            - os:reader
          allowedKubernetesNamespaces:
            - kube-system
    EOT
    ,
    yamlencode({
      machine = {
        certSANs = concat([
          var.kube_apiserver_domain,
          oci_network_load_balancer_network_load_balancer.network_load_balancer.ip_addresses[0].ip_address,
          ],
          [for k, v in oci_core_instance.controlplane : v.public_ip]
        )
      }
      cluster = {
        apiServer = {
          certSANs = concat([
            var.kube_apiserver_domain,
            oci_network_load_balancer_network_load_balancer.network_load_balancer.ip_addresses[0].ip_address,
            ],
            [for k, v in oci_core_instance.controlplane : v.public_ip]
          )
        }
      }
    }),
  ]
}
