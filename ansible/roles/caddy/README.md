# caddy

Installs [Caddy](https://caddyserver.com) from its apt repository, as `install/caddy-install.sh` does.

The work is done by [`maxhoesel.caddy.caddy_server`](https://github.com/maxhoesel-ansible/ansible-collection-caddy), which uses the same repository and installs the same packages as Upstream. This role adds a version pin and the default that makes the result match Upstream. Everything else is configured with that role's own `caddy_*` variables.

## Variables

| Variable | Default | |
|---|---|---|
| `caddy_version` | `""` | Version of the `caddy` package to hold the host at. Empty installs the newest. |
| `caddy_manage_config` | `false` | Leave the packaged Caddyfile in place, as Upstream does. Set to `true` to manage the configuration through `caddy_caddyfile` or `caddy_json_config`. |
| `caddy_config_format` | `Caddyfile` | `Caddyfile` runs the `caddy` service, as Upstream does. `json` runs `caddy-api` instead. |

The underlying role defaults to applying an empty JSON configuration, which replaces the `caddy` service with `caddy-api`. To end up where Upstream does, this role sets that role's `caddy_apply_config` and `caddy_config_mode` from the two variables above; setting those directly has no effect.

## Plugins

Upstream offers to install `xcaddy`. This role does not. Add plugins with `caddy_custom_additional_modules`:

```yaml
caddy_custom_additional_modules:
  - github.com/caddy-dns/cloudflare
```

The underlying role then runs a separate binary, downloaded from Caddy's build service, and upgrades it daily unless `caddy_custom_update_timer_enabled` is `false`. `caddy_version` pins the package only, not that binary: its version is whatever the build service served when it was last downloaded.

## Updating

Run the role again. Upstream's `update` runs `apt upgrade`; here a new `caddy_version`, or an empty one, moves the package.
