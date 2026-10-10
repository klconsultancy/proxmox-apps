# caddy

Installs [Caddy](https://caddyserver.com) from its apt repository, as `install/caddy-install.sh` does.

The installation is this role's own: the same packages and the same repository as Upstream. Configuration and plugins are handed to [`maxhoesel.caddy.caddy_server`](https://github.com/maxhoesel-ansible/ansible-collection-caddy), using its task files for those two things only. That role's own installation refreshes the package lists unconditionally, which fails the run whenever any third-party repository on the host is unreachable.

## Variables

| Variable | Default | |
|---|---|---|
| `caddy_version` | `""` | Version of the `caddy` package to hold the host at. Empty installs the newest. |
| `caddy_manage_config` | `false` | Leave the packaged Caddyfile in place, as Upstream does. Set to `true` to apply `caddy_caddyfile` or `caddy_json_config`. |
| `caddy_config_format` | `Caddyfile` | `Caddyfile` runs the `caddy` service, as Upstream does. `json` runs `caddy-api` instead. |

`caddy_caddyfile`, `caddy_json_config`, `caddy_custom_additional_modules` and `caddy_custom_update_timer_enabled` are variables of the underlying role and keep their meaning. Its `caddy_config_mode` is set from `caddy_config_format`, and its `caddy_apply_config` is not used.

## Plugins

Upstream offers to install `xcaddy`. This role does not. Add plugins with `caddy_custom_additional_modules`:

```yaml
caddy_custom_additional_modules:
  - github.com/caddy-dns/cloudflare
```

The underlying role then runs a separate binary, downloaded from Caddy's build service, and upgrades it daily unless `caddy_custom_update_timer_enabled` is `false`. `caddy_version` pins the package only, not that binary: its version is whatever the build service served when it was last downloaded.

## Updating

Run the role again. Upstream's `update` runs `apt upgrade`; here a new `caddy_version`, or an empty one, moves the package.

## When a repository is unreachable

The package lists are refreshed once, at the start. If that fails, the role says so and continues with the lists the host already has. On a host where Caddy is installed, the run completes; installing Caddy for the first time still needs its repository.
