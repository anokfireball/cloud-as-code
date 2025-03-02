resource "random_pet" "node" {
  count     = var.node_count
  length    = 2
  separator = "-"
}

resource "oci_core_instance" "node" {
  for_each = { for idx, val in random_pet.node : idx => val }
  # choose the next availability domain which wasn't last
  availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains[each.key % length(data.oci_identity_availability_domains.availability_domains.availability_domains)].name
  compartment_id      = var.compartment_ocid
  shape               = var.instance_shape
  shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory_in_gbs
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.subnet_regional.id
    nsg_ids          = [oci_core_network_security_group.network_security_group.id]
  }
  agent_config {
    are_all_plugins_disabled = true
    is_management_disabled   = true
    is_monitoring_disabled   = true
  }
  availability_config {
    is_live_migration_preferred = true
    recovery_action             = "RESTORE_INSTANCE"
  }
  #Optional
  display_name = "${var.cluster_name}-control-plane-${each.value.id}"
  launch_options {
    #Optional
    network_type            = local.instance_mode
    remote_data_volume_type = local.instance_mode
    boot_volume_type        = local.instance_mode
    firmware                = "UEFI_64"
  }
  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }
  source_details {
    #Required
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }
  preserve_boot_volume = false

  lifecycle {
    create_before_destroy = "true"
    ignore_changes = [
      defined_tags
    ]
  }
  metadata = {
    "ssh_authorized_keys" = file(var.ssh_public_key_path)
  }
}
