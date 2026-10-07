mock_provider "proxmox" {}

variables {
  node_name    = "pve"
  vm_id        = 100
  hostname     = "test"
  os_template  = "local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst"
  os_type      = "debian"
  cpu_cores    = 1
  memory       = 512
  disk_size    = 2
  ipv4_address = "192.0.2.10/24"
  ipv4_gateway = "192.0.2.1"
}

run "defaults" {
  command = plan

  assert {
    condition     = proxmox_virtual_environment_container.this.unprivileged
    error_message = "Containers are unprivileged unless asked otherwise."
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.features[0].nesting
    error_message = "Nesting is on by default, as upstream."
  }

  assert {
    condition     = !proxmox_virtual_environment_container.this.features[0].keyctl
    error_message = "keyctl is off by default, unlike upstream."
  }

  assert {
    condition     = length(proxmox_virtual_environment_container.this.device_passthrough) == 0
    error_message = "No devices are passed through by default."
  }

  assert {
    condition     = output.ipv4_address == "192.0.2.10"
    error_message = "The output strips the prefix length."
  }
}

run "tun" {
  command = plan

  variables {
    tun = true
    devices = [
      { path = "/dev/dri/renderD128", gid = 104 },
    ]
  }

  assert {
    condition     = proxmox_virtual_environment_container.this.device_passthrough[0].path == "/dev/net/tun"
    error_message = "tun passes /dev/net/tun through."
  }

  assert {
    condition     = length(proxmox_virtual_environment_container.this.device_passthrough) == 2
    error_message = "tun is added to the explicitly listed devices."
  }
}

run "dhcp" {
  command = plan

  variables {
    ipv4_address = "dhcp"
    ipv4_gateway = null
  }

  assert {
    condition     = output.ipv4_address == null
    error_message = "There is no static address to report with dhcp."
  }
}

run "rejects_address_without_prefix" {
  command = plan

  variables {
    ipv4_address = "192.0.2.10"
  }

  expect_failures = [var.ipv4_address]
}
