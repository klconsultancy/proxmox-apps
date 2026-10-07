variable "node_name" {
  description = "Proxmox node the container is created on."
  type        = string
}

variable "vm_id" {
  description = "Container ID."
  type        = number
}

variable "hostname" {
  type = string
}

variable "description" {
  type    = string
  default = null
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "os_template" {
  description = "Template file ID, e.g. `local:vztmpl/debian-13-standard_13.1-2_amd64.tar.zst`. Only read at creation."
  type        = string
}

variable "os_type" {
  description = "Proxmox OS type of the template, e.g. `debian`."
  type        = string
}

variable "cpu_cores" {
  type = number
}

variable "memory" {
  description = "Dedicated memory in MB."
  type        = number
}

variable "swap" {
  description = "Swap in MB."
  type        = number
  default     = 512
}

variable "disk_size" {
  description = "Root disk size in GB."
  type        = number
}

variable "datastore_id" {
  description = "Datastore for the root disk."
  type        = string
  default     = "local-lvm"
}

variable "mount_points" {
  type = list(object({
    path      = string
    volume    = string
    size      = optional(string)
    backup    = optional(bool, false)
    read_only = optional(bool, false)
  }))
  default = []
}

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "vlan_id" {
  type    = number
  default = null
}

variable "mac_address" {
  description = "Leave null to let Proxmox generate one."
  type        = string
  default     = null
}

variable "mtu" {
  type    = number
  default = null
}

variable "firewall" {
  description = "Enable the Proxmox firewall on the network interface."
  type        = bool
  default     = false
}

variable "ipv4_address" {
  description = "IPv4 address in CIDR notation, or `dhcp`."
  type        = string

  validation {
    condition     = var.ipv4_address == "dhcp" || can(cidrhost(var.ipv4_address, 0))
    error_message = "ipv4_address must be `dhcp` or an address in CIDR notation, e.g. `192.0.2.10/24`."
  }
}

variable "ipv4_gateway" {
  description = "IPv4 gateway. Leave null with `dhcp`."
  type        = string
  default     = null
}

variable "ipv6_address" {
  description = "IPv6 address in CIDR notation, `dhcp` or `auto`. Null leaves IPv6 unconfigured."
  type        = string
  default     = null
}

variable "ipv6_gateway" {
  type    = string
  default = null
}

variable "dns_servers" {
  description = "DNS servers, primary first. Empty uses the node's settings."
  type        = list(string)
  default     = []
}

variable "dns_search_domain" {
  description = "DNS search domain. Null uses the node's setting."
  type        = string
  default     = null
}

variable "ssh_authorized_keys" {
  description = "Public keys for root. Only read at creation. No password is ever set."
  type        = list(string)
  default     = []
}

variable "unprivileged" {
  type    = bool
  default = true
}

variable "start_on_boot" {
  type    = bool
  default = true
}

variable "protection" {
  description = "Protect the container and its disks from removal."
  type        = bool
  default     = false
}

variable "nesting" {
  description = "Upstream enables nesting on every container; systemd in a recent distribution needs it."
  type        = bool
  default     = true
}

variable "keyctl" {
  description = <<-EOT
    Upstream enables keyctl on every unprivileged container so Docker can run
    in it. Off here: it weakens isolation and only Docker-in-LXC needs it.
    Setting any feature other than nesting requires authenticating as root@pam.
  EOT
  type        = bool
  default     = false
}

variable "fuse" {
  type    = bool
  default = false
}

variable "mknod" {
  type    = bool
  default = false
}

variable "mount_fs" {
  description = "Filesystem types the container may mount, e.g. `[\"nfs\", \"cifs\"]`."
  type        = list(string)
  default     = []
}

variable "tun" {
  description = "Pass /dev/net/tun into the container, for VPN software. Requires authenticating as root@pam."
  type        = bool
  default     = false
}

variable "devices" {
  description = <<-EOT
    Host devices to pass into the container, e.g. a GPU render node or a USB
    serial adapter. Upstream detects these on the host; here they are named
    explicitly. Requires authenticating as root@pam.
  EOT
  type = list(object({
    path       = string
    gid        = optional(number)
    uid        = optional(number)
    mode       = optional(string)
    deny_write = optional(bool)
  }))
  default = []
}
