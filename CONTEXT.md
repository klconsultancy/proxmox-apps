# proxmox-apps

Declarative Terraform and Ansible equivalents of the community-scripts Proxmox VE helper scripts, for people who want the community's install knowledge without running interactive shell scripts.

## Language

### Source

**Upstream**:
The `community-scripts/ProxmoxVE` and `community-scripts/core` repositories, from which every App Module and App Role is derived.
_Avoid_: the scripts, helper scripts, tteck

**App**:
One installable piece of software that Upstream ships as a `ct/<app>.sh` and `install/<app>-install.sh` pair, identified by its Upstream script name.
_Avoid_: service, script, package

**Helper**:
A shared Upstream shell function that several install scripts call, such as `setup_nodejs` or `fetch_and_deploy_gh_release`.
_Avoid_: tool, function, util

### Translation

**Same End State**:
The measure of a correct translation: the machine ends up with the same packages, repositories, paths, units and ports as after running the Upstream script. Interactive menus, telemetry and MOTD changes are not part of it.
_Avoid_: 1-to-1, port, parity

**Generic Module**:
A Terraform module that creates a container or VM with given properties and knows nothing about any App.
_Avoid_: base module, core module

**App Module**:
A thin Terraform module for one App that calls a Generic Module with the Upstream resource values and container requirements as overridable defaults.
_Avoid_: catalog, wrapper, preset

**App Role**:
The Ansible role that installs and updates one App.
_Avoid_: install role, playbook

**Shared Layer**:
The Ansible building blocks that App Roles have in common, standing in for the Helpers: a built-in module where one fits, an existing community role or collection where one exists, and an own role only where neither does.
_Avoid_: common, lib, tools

**Deviation**:
A deliberate, recorded difference from what Upstream does. Access and hardening choices are always Deviations: Upstream decides what is installed and how, not who can log in.
_Avoid_: override, exception, fix

### Staying in sync

**Manifest**:
The record of which Upstream files and commit each App Module, App Role and Shared Layer part was derived from, together with its Deviations.
_Avoid_: mapping, lockfile, index

**Drift**:
An Upstream change to a file the Manifest references that has not yet been reviewed against its translation.
_Avoid_: out of date, stale
