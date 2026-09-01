# Flyway + GitHub Actions Pipelines - SE Reference

Reference for the sample pipelines in **`Flyway-Sample-Pipelines/github-actions/workflows/`**. That folder contains the same three-stage SQL Server pipeline (Build -> QA -> Production) implemented two ways:

| Folder | How Flyway runs |
|---|---|
| **`flyway-cli/`** | Raw `flyway ...` commands in `run:` steps. Requires the Flyway CLI pre-installed on the runner. |
| **`flyway-actions/`** | Official Redgate actions: `red-gate/setup-flyway@v3` + `red-gate/flyway-actions/*@v2`. No pre-install - the CLI is downloaded and licensed per job. |

Both folders consume an **identical set of variables and secrets**, so a client can set up GitHub once and run either variant - or switch between them - without touching settings. Each file's header comment cross-references its counterpart.

All schema changes are applied through versioned migration scripts generated with Flyway Desktop. There is no application code.

---

## Choosing a Variant

| | **`flyway-cli/`** | **`flyway-actions/`** |
|---|---|---|
| Flyway install | Manual, on the runner's `PATH` | `setup-flyway` per job, pinned via `version:` |
| Licensing | `-email`/`-token`/`-IAgreeToTheEula` repeated on every command | Once per job in the setup step |
| Reports | Written to disk; published with an explicit `upload-artifact` step | Uploaded as workflow artifacts automatically |
| Code scanning | Not wired up | Code review SARIF pushed to GitHub Code Scanning automatically |
| Snapshots for drift | Not stored (add `-migrate.saveSnapshot=true` to enable) | Stored on every deploy by default |
| Best for | Air-gapped runners, or where downloads are blocked | Most teams - less YAML, more built-in behavior |

**Default recommendation: `flyway-actions/`.** Reach for `flyway-cli/` when the runner can't download from the internet or the client wants full visibility of every CLI flag.

> In `flyway-actions/`, keep the major versions consistent (`@v3` for setup, `@v2` for the rest). Redgate does not support mixing them.

---

## Prerequisites

- **Flyway Enterprise license** - a token (PAT) and registered email from [Redgate](https://www.red-gate.com/products/flyway/enterprise/).
- **Flyway Desktop** on the development machine - generates versioned migrations and keeps `schema-model/` in sync.
- **Self-hosted GitHub Actions runner** - the samples assume Windows (`shell: cmd` / `pwsh`); notes in each file cover Linux. See [GitHub docs](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners).
  - `flyway-cli/` only: the `flyway` CLI must already be on the runner's `PATH`.
  - `flyway-actions/` only: outbound HTTPS so `setup-flyway` can download the CLI.
- **SQL Server databases** - Build, QA, PROD1, PROD2, plus a **Check** database used as the throwaway build/shadow DB for drift and change reports.
- **SQL Server Authentication enabled** - the workflows authenticate with username/password. In SSMS: *Server Properties -> Security -> SQL Server and Windows Authentication mode*.

### Windows self-hosted runners - Git Bash requirement (`flyway-actions/` only)

The Redgate actions are composites whose internal steps declare `shell: bash`. Git for Windows' default install puts only `Git\cmd` on `PATH` (git.exe, **no bash.exe**), so `shell: bash` resolves to WSL's `C:\Windows\System32\bash.exe`, which cannot read Windows script paths. The failure looks like:

```
/bin/bash: C:ProjectsExample...sh: No such file or directory
```

Every `flyway-actions/` workflow includes this step (auto-skipped on Linux):

```yaml
- name: Add Git Bash to PATH
  if: runner.os == 'Windows'
  shell: pwsh
  run: |
    "C:\Program Files\Git\bin" | Out-File $env:GITHUB_PATH -Append -Encoding utf8
    "C:\Program Files\Git\usr\bin" | Out-File $env:GITHUB_PATH -Append -Encoding utf8
```

`Git\bin` provides `bash.exe`; `Git\usr\bin` provides `gzip`, without which the runner tool cache can't be saved and Flyway is re-downloaded every run. Alternatively, add both paths to the **machine** `PATH` ahead of `System32` and restart the runner service.

---

## One-Time Setup with the Client

Work through this whole section with the client in one sitting - everything the pipelines need is provisioned here, before opening a single workflow file. Checklist:

- [ ] **6 repository variables** (connection strings + license email)
- [ ] **12 repository secrets** (license token, undo target, 5 credential pairs)
- [ ] **2 environment blocks in `flyway.toml`** (`check`, and `build` for `flyway-actions/`)

### Variables and Secrets

Every env var maps 1:1 to an identically-named variable or secret - a client reads a workflow's `env:` block and knows exactly what to create. Both folders use the same set.

**Variables** (*Settings -> Secrets and variables -> Actions -> Variables*):

| Variable | Description |
|---|---|
| `USER_EMAIL` | Email registered to the Flyway Enterprise license |
| `JDBC_BUILD` | JDBC connection string for the Build database |
| `JDBC_QA` | JDBC connection string for the QA database |
| `JDBC_CHECK` | JDBC connection string for the Check database (throwaway - wiped every run) |
| `JDBC_PROD1` | JDBC connection string for Production database 1 |
| `JDBC_PROD2` | JDBC connection string for Production database 2 |

```
jdbc:sqlserver://<host>;databaseName=<db>;trustServerCertificate=true
```

**Secrets** (*Settings -> Secrets and variables -> Actions -> Secrets*):

| Secret | Description |
|---|---|
| `FLYWAY_TOKEN` | Flyway Enterprise license token (PAT) |
| `FIRST_UNDO_SCRIPT` | Earliest migration version the Build pipeline validates undo back to (e.g. `001`) |
| `DB_USER_BUILD` / `DB_USER_PW_BUILD` | Build database login |
| `DB_USER_QA` / `DB_USER_PW_QA` | QA database login |
| `DB_USER_CHECK` / `DB_USER_PW_CHECK` | Check database login |
| `DB_USER_PROD1` / `DB_USER_PW_PROD1` | Production 1 login |
| `DB_USER_PROD2` / `DB_USER_PW_PROD2` | Production 2 login |

A demo environment can point several of these at the same underlying SQL login - the 1:1 naming still holds, and moving to real per-environment logins later means changing secret *values* only, never the workflow files.

> Connection strings and credentials live in GitHub settings, **never in `flyway.toml`** - clients will not accept connection details in the repo. The committed config declares environments with `url = ""` and the real values are injected at runtime.

---

### `flyway.toml` - Required Updates

The project config the pipelines expect (committed to the client's repo alongside `migrations/` and `schema-model/`):

```toml
[environments.check]
url = ""
provisioner = "clean"

[environments.build]        # flyway-actions/ only - used by provision-mode: reprovision
url = ""
provisioner = "clean"
```

- Environments that exist only to carry a setting (a provisioner) are declared with `url = ""`; the runtime value wins. The actions emit `-environment=build -environments.build.url=...`; the CLI samples pass `-environments.check.url=...` explicitly.
- **Allowing clean:** Flyway disables `clean` by default. The samples re-enable it only for throwaway databases, from the workflow rather than committed config: the CLI passes `-cleanDisabled="false"` only on the step that cleans (scoped `-environments.check.flyway.cleanDisabled=false` on the check command); the actions use `extra-args` on Build and `build-ok-to-erase: true` on checks. QA and Production are never clean-enabled.
- Recommended settings the samples assume: `validateMigrationNaming = true`, `mixed = true`, and `outOfOrder = true` if parallel feature branches are in play.

---

## The Three Workflows

Identical structure in both folders. All trigger on push to their branch, filtered to `paths: "migrations/**"`.

### `deploy-build.yml` - Build validation (push to `Development`)

Validates the migration, its undo script, and produces the report reviewed on the pull request:

1. **Clean + Migrate Build** - rebuilds the Build DB from scratch. (`flyway-cli`: separate `clean` and `migrate` steps. `flyway-actions`: one deploy step with `provision-mode: reprovision`.)
2. **Rollback Build** - undoes back to `FIRST_UNDO_SCRIPT`, validating every undo script in between.
3. **QA Check Report** - code analysis, deployment changes, drift and dry run against QA, published as a workflow artifact for PR review.

If any step fails, nothing should be promoted to QA. Drift checking and snapshots are deliberately disabled against the Build DB - it is wiped every run, so drift against it is meaningless.

### `deploy-qa.yml` - QA deployment (push to `QA`)

Applies pending migrations to the QA database. In `flyway-actions/` the deploy also runs a drift check first and stores a snapshot after - the snapshot is what makes the drift section of the next build report meaningful.

### `deploy-prod.yml` - Production deployment (push to `Production`)

Three jobs:

1. **Generate Report** - code review, changes, drift and dry run against PROD2, using the Check database as the build environment. Configured report-only (`continue-on-error` in `flyway-cli/`; `fail-on-drift: false` + `fail-on-code-review: false` in `flyway-actions/`) so the report never blocks the deploy jobs.
2. **Deploy Prod 1** and **Deploy Prod 2** - both `needs: flyway-report`, run in parallel (demonstrating multi-tenant deployment; on a single runner they queue).

In `flyway-actions/`, **drift is fatal on the deploy jobs** - the action aborts with `Drift detected. Aborting deployment.` and does not write a new snapshot, so an out-of-band hotfix cannot be silently absorbed into the baseline.

> GitHub Actions has no native manual approval gate. To add one, configure a [GitHub Environment](https://docs.github.com/en/actions/deployment/targeting-different-deployment-environments) with required reviewers and set `environment:` on the deploy jobs.

---

## Reports and Artifacts

| Workflow | `flyway-cli/` artifact | `flyway-actions/` artifact |
|---|---|---|
| Build | `flyway-qa-check-report` (explicit upload step) | `flyway-qa-pre-deployment-report` (automatic) |
| QA | - | `flyway-qa-deployment-report` (when a report is generated) |
| Prod report | `flyway-prod-check-report` (explicit upload step) | `flyway-prod-pre-deployment-report` (automatic) |
| Prod deploys | - | `flyway-prod1/2-deployment-report` (when a report is generated) |

Download from the run's **Artifacts** section, or the links in the job summary (`flyway-actions/`).

The CLI upload steps use `if: always()` (the report survives a failed check - that's when you most need it) and `if-no-files-found: warn` (a missing report annotates the run instead of shipping an empty green artifact). Reports are written to and uploaded from the runner **workspace** - never a machine-specific path.

The `flyway-actions/` workflows that run checks also push code review SARIF to **GitHub Code Scanning**, which requires:

```yaml
permissions:
  contents: read
  security-events: write
```

A declared `permissions` block replaces the defaults, so `contents: read` must be listed or checkout breaks.

---

## Migration Conventions (Flyway Desktop projects)

```
V{version}_{timestamp}__{description}.sql       # Versioned migration
U{version}_{timestamp}__UNDO-{description}.sql  # Paired undo script
```

- Zero-padded versions (`V001`, `V020`); timestamps `YYYYMMDDHHmmss`; `V`/`U` version numbers must match.
- Scripts start with the Flyway Desktop SET statements block; separate logical blocks with `GO`; log with `PRINT N'...'`.
- Undo scripts fully reverse the paired migration; `EXEC sp_refreshview` for views affected by table changes.

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Duplicate table ... [environments.check]` | Flyway Desktop appended a second environment block to `flyway.toml` (TOML forbids repeated tables) | Delete the duplicate block. Check after any Desktop rewrite of the file - **merging a fixed branch in does not remove it**; it must be deleted on each affected branch |
| `/bin/bash: C:Projects...: No such file or directory` | `shell: bash` resolved to WSL bash (Windows runner) | Add the *Add Git Bash to PATH* step (see above) |
| `Unable to execute clean as it has been disabled` | `cleanDisabled` defaults to `true` | Scope it: `-environments.<env>.flyway.cleanDisabled=false`, or `build-ok-to-erase: true` on the checks action |
| `No snapshot located to use for drift analysis` | No deployment has stored a snapshot yet | Expected on first run - resolves after a deploy that saves a snapshot (`flyway-actions/` deploys do this by default) |
| Checks action falls back to a Docker build DB | `build-url`/`build-user`/`build-password` omitted | Always supply all three (plus `build-environment`) |
| `Drift detected. Aborting deployment.` | Out-of-band change on the target since the last snapshot | Intended behavior. Reconcile the drift (or fold it into a migration), then re-run |
| Report artifact is empty / missing | Check step failed before writing, or report path doesn't match upload path | Read the check step log; keep report path and upload path both on `${{ github.workspace }}` |
| Flyway re-downloaded every run (`flyway-actions/`) | Tool cache save fails: `gzip: command not found` | `Git\usr\bin` missing from PATH - the Git Bash step above fixes this too |
