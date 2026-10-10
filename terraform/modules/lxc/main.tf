locals {
  # Upstream binds /dev/net/tun with raw lxc.* lines in the container config,
  # which the provider cannot write; device passthrough is the supported way.
  tun_device = {
    path       = "/dev/net/tun"
    gid        = null
    uid        = null
    mode       = null
    deny_write = null
  }

  devices = concat(var.tun ? [local.tun_device] : [], var.devices)
}

resource "proxmox_virtual_environment_container" "this" {
  node_name   = var.node_name
  vm_id       = var.vm_id
  description = var.description
  tags        = var.tags

  unprivileged  = var.unprivileged
  start_on_boot = var.start_on_boot
  protection    = var.protection

  operating_system {
    template_file_id = var.os_template
    type             = var.os_type
  }

  cpu {
    cores = var.cpu_cores
  }

  memory {
    dedicated = var.memory
    swap      = var.swap
  }

  disk {
    datastore_id = var.datastore_id
    size         = var.disk_size
  }

  dynamic "mount_point" {
    for_each = var.mount_points
    content {
      path      = mount_point.value.path
      volume    = mount_point.value.volume
      size      = mount_point.value.size
      backup    = mount_point.value.backup
      read_only = mount_point.value.read_only
    }
  }

  network_interface {
    name        = "eth0"
    bridge      = var.bridge
    vlan_id     = var.vlan_id
    mac_address = var.mac_address
    mtu         = var.mtu
    firewall    = var.firewall
  }

  initialization {
    hostname = var.hostname

    dynamic "dns" {
      for_each = length(var.dns_servers) > 0 || var.dns_search_domain != null ? [1] : []
      content {
        servers = var.dns_servers
        domain  = var.dns_search_domain
      }
    }

    ip_config {
      ipv4 {
        address = var.ipv4_address
        gateway = var.ipv4_gateway
      }

      dynamic "ipv6" {
        for_each = var.ipv6_address != null ? [1] : []
        content {
          address = var.ipv6_address
          gateway = var.ipv6_gateway
        }
      }
    }

    dynamic "user_account" {
      for_each = length(var.ssh_authorized_keys) > 0 ? [1] : []
      content {
        keys = var.ssh_authorized_keys
      }
    }
  }

  features {
    nesting = var.nesting
    keyctl  = var.keyctl
    fuse    = var.fuse
    mknod   = var.mknod
    mount   = var.mount_fs
  }

  dynamic "device_passthrough" {
    for_each = local.devices
    content {
      path       = device_passthrough.value.path
      gid        = device_passthrough.value.gid
      uid        = device_passthrough.value.uid
      mode       = device_passthrough.value.mode
      deny_write = device_passthrough.value.deny_write
    }
  }

  lifecycle {
    # Both are only read at creation; a change would otherwise replace the
    # container to apply something that has no effect on a running one.
    ignore_changes = [
      initialization[0].user_account,
      operating_system[0].template_file_id,
    ]
  }
}
