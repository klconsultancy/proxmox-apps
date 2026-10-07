# proxmox-apps

Terraform and Ansible equivalents of the [community-scripts](https://github.com/community-scripts/ProxmoxVE) Proxmox VE helper scripts.

The community-scripts project holds a large body of knowledge on how to install software on Proxmox VE, in the form of interactive shell scripts. This repository translates that knowledge into declarative code:

| Upstream | Here |
|---|---|
| `build.func` (container creation) | a generic Terraform module on the [`bpg/proxmox`](https://registry.terraform.io/providers/bpg/proxmox/latest) provider |
| `ct/<app>.sh` (per-app defaults) | a thin Terraform module per app |
| `install/<app>-install.sh` | an Ansible role per app |
| shared helpers (`tools.func`) | built-in Ansible modules and existing community collections first, own roles only where neither exists |

A translation is correct when the machine ends up in the same state as after running the upstream script. Where this repository deliberately differs — access and hardening in particular — the difference is recorded.

See [`CONTEXT.md`](CONTEXT.md) for the vocabulary and [`docs/adr/`](docs/adr/) for the decisions behind the approach.

## Status

Early. The generic `lxc` module exists; no apps are translated yet.

## License

MIT. Derived from community-scripts/ProxmoxVE and community-scripts/core, also MIT; see [`LICENSE`](LICENSE).
