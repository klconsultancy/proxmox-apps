# klconsultancy.proxmox_apps

One role per App, each installing what the matching community-scripts install script installs. See the [repository README](../README.md).

| Role | Upstream | Built on |
|---|---|---|
| [`caddy`](roles/caddy/README.md) | `install/caddy-install.sh` | `maxhoesel.caddy`, for configuration and plugins |

## Install

```yaml
# requirements.yml
collections:
  - name: git+https://github.com/klconsultancy/proxmox-apps.git#/ansible/
    type: git
    version: main
```
