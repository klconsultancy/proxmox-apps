# Hand translation with a Manifest and a Drift check

Upstream is roughly 600 App scripts plus ~25,000 lines of shared shell, and it changes daily. We translate each App by hand (AI-assisted) into an App Module and an App Role, record in the Manifest which Upstream files and commit each part was derived from, and run a scheduled check that reports Drift. We chose this because it is the only option that yields idempotent, reviewable Terraform and Ansible while still letting the community's changes reach us as a visible signal.

## Considered Options

**A generator that converts shell to Ansible.** Rejected: only the `var_*` resource lines in `ct/<app>.sh` are regular enough to parse. Install scripts are free-form bash, and a generator would either cover a fraction of them or emit `shell:` tasks that are the script again with extra steps.

**Ansible that runs the Upstream install script unchanged.** Gives full coverage of every App for almost no work, and stays current for free. Rejected: it is not idempotent, cannot pin a version, brings along Upstream's access and convenience choices, and leaves us with the shell scripts we set out to replace.

## Consequences

- Coverage grows one App at a time. An App that is not translated does not exist here.
- The Manifest is load-bearing: a translation without a Manifest entry cannot Drift visibly, so it is not done.
- Drift is tracked per file for App scripts and per function for Helpers. `tools.func` alone is over 10,000 lines; file-level tracking there would flag every App on every change.
- The Drift check compares against Upstream directly, not against a fork.
- Deviations live in the Manifest so that an Upstream change does not reopen a decision that was already made.
