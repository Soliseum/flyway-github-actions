# Copilot Instructions for DemoDB

## Overview

This repo demonstrates a **Flyway Enterprise + GitHub Actions** pipeline for automating SQL Server database deployments across Build, QA, and Production environments. It is intended as a working reference for teams looking to adopt database DevOps with Flyway Desktop and self-hosted GitHub Actions runners.

All schema changes are applied through versioned migration scripts. There is no application code.

---

## Two Ways to Run Flyway

There are two supported ways to invoke Flyway from a workflow. **The workflows in `.github/workflows/` use Option B.** Option A remains documented because it is still valid and some teams prefer it.

| | **Option A - Pre-installed CLI** | **Option B - Redgate Actions** (current) |
|---|---|---|
| How Flyway gets there | Installed manually on the runner, on `PATH` | `red-gate/setup-flyway@v3` downloads it per job |
| How commands run | `run:` steps calling `flyway ...` directly | `red-gate/flyway-actions/*@v2` steps |
| Version control | Whatever is installed on the machine | Pinned via the `version` input |
| Reports | Written wherever `-reportFilename` points; you upload them yourself | Uploaded as workflow artifacts automatically |
| Code scanning | Manual SARIF upload | SARIF pushed to GitHub Code Scanning automatically |
| Best for | Air-gapped runners, or where downloads are blocked | Most teams - less YAML, portable across runners |

Both options need the same variables, secrets, and `flyway.toml`. Switching between them only changes the step bodies.

### Option A - pre-installed CLI

Install the Flyway CLI on the runner and make sure it is on `PATH`. Steps then call it directly:

```yaml
- name: Migrate
  shell: cmd
  run: >
    flyway -email=${{ env.EMAIL }} -token=${{ env.TOKEN }} migrate
    -user=${{ env.DB_USER_QA }} -password=${{ env.DB_USER_PW_QA }}
    -url=${{ env.JDBC_QA }} -IAgreeToTheEula
    -configFiles="${{ github.workspace }}/flyway.toml"
```

Licensing (`-email` / `-token` / `-IAgreeToTheEula`) must be repeated on **every** command.

### Option B - Redgate GitHub Actions (used by this repo)

`setup-flyway` installs and licenses the CLI once per job; the `flyway-actions` steps then run against it:

```yaml
- name: Setup Flyway
  uses: red-gate/setup-flyway@v3
  with:
    version: "13.4.0" # Pin for reproducible runs - bump deliberately
    edition: enterprise
    i-agree-to-the-eula: true
    email: ${{ env.EMAIL }}
    token: ${{ env.TOKEN }}

- name: Migrate
  uses: red-gate/flyway-actions/migrations/deploy@v2
  with:
    target-url: ${{ env.JDBC_QA }}
    target-user: ${{ env.DB_USER_QA }}
    target-password: ${{ env.DB_USER_PW_QA }}
```

Actions used in this repo:

| Action | Purpose |
|---|---|
| `red-gate/setup-flyway@v3` | Installs the Flyway CLI and authenticates the licence |
| `red-gate/flyway-actions/migrations/deploy@v2` | Applies pending migrations |
| `red-gate/flyway-actions/migrations/undo@v2` | Rolls back migrations to a target version |
| `red-gate/flyway-actions/migrations/checks@v2` | Code review, changes, drift and dry-run report |

> Keep the major versions consistent (`@v3` for setup, `@v2` for the rest). Redgate does not support mixing them.

---

## Prerequisites

- **Flyway Enterprise license** - a token and registered email from [Redgate](https://www.red-gate.com/products/flyway/enterprise/).
- **Flyway Desktop** (optional, recommended for local development) - used to generate versioned migration scripts and keep `schema-model/` in sync.
- **Self-hosted GitHub Actions runner** - a Windows machine registered to this repository. See [GitHub docs](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners).
  - **Option A only:** the `flyway` CLI must already be on the runner's `PATH`.
  - **Option B:** no pre-install needed - `setup-flyway` handles it. Requires outbound HTTPS.
- **SQL Server instances** - at minimum: Build, QA, and Production databases, plus a Check database used as the throwaway build/shadow DB for drift and change reports.
- **SQL Server Authentication enabled** - workflows authenticate with a username and password. In SSMS go to *Server Properties -> Security* and set **SQL Server and Windows Authentication mode**.

### Windows self-hosted runners - Git Bash requirement

The `flyway-actions` steps are composite actions whose internal steps declare `shell: bash`. The default Git for Windows install option adds only `C:\Program Files\Git\cmd` to `PATH`, which contains `git.exe` but **no `bash.exe`**. When that happens `shell: bash` resolves to WSL's `C:\Windows\System32\bash.exe`, which cannot read Windows script paths, and the step fails with:

```
/bin/bash: C:ProjectsDemoDB...sh: No such file or directory
```

Every workflow includes a step that fixes this. It is skipped automatically on Linux runners:

```yaml
- name: Add Git Bash to PATH
  if: runner.os == 'Windows'
  shell: pwsh
  run: |
    "C:\Program Files\Git\bin" | Out-File $env:GITHUB_PATH -Append -Encoding utf8
    "C:\Program Files\Git\usr\bin" | Out-File $env:GITHUB_PATH -Append -Encoding utf8
```

`Git\bin` provides `bash.exe`; `Git\usr\bin` provides `gzip`, without which the runner tool cache cannot be saved and Flyway is re-downloaded every run.

Alternatively, add both paths to the **machine** `PATH` ahead of `System32` and restart the runner service - then the workflow step is unnecessary.

---

## Repository Structure

```
migrations/          # Versioned (V) and undo (U) migration scripts - applied in order
schema-model/        # Declarative schema snapshot maintained by Flyway Desktop - do not hand-edit
flyway.toml          # Shared project config (committed) - environments, comparison options, filters
flyway.user.toml     # Local user config (not committed) - JDBC URLs for dev/shadow environments
Filter.scpf          # Redgate SQL Compare filter - controls which objects are included in comparisons
.github/workflows/   # CI/CD pipeline definitions
```

---

## Getting Started

### 1. Fork or clone this repository

Use this repo as a starting point. Replace the contents of `migrations/` and `schema-model/` with your own database schema.

### 2. Register a self-hosted runner

In your GitHub repository go to **Settings -> Actions -> Runners -> New self-hosted runner** and follow the instructions for Windows.

### 3. Configure GitHub Actions Variables

Go to **Settings -> Secrets and variables -> Actions -> Variables** and create the following:

| Variable | Description |
|---|---|
| `USER_EMAIL` | Email address associated with your Flyway Enterprise license |
| `JDBC_BUILD` | JDBC connection string for the Build database |
| `JDBC_QA` | JDBC connection string for the QA database |
| `JDBC_PROD1` | JDBC connection string for Production database 1 |
| `JDBC_PROD2` | JDBC connection string for Production database 2 |
| `JDBC_CHECK` | JDBC connection string for the Check database (throwaway build DB for reports) |

JDBC connection string format:
```
jdbc:sqlserver://<host>;databaseName=<db>;trustServerCertificate=true
```

> Connection strings are stored as **repository variables, never in `flyway.toml`**. The committed config declares environments with `url = ""` and the real value is supplied at runtime - see [Key Flyway Settings](#key-flyway-settings-flywaytoml).

### 4. Configure GitHub Actions Secrets

Go to **Settings -> Secrets and variables -> Actions -> Secrets** and create the following:

| Secret | Description |
|---|---|
| `FLYWAY_TOKEN` | Flyway Enterprise license token |
| `DB_USER_NAME_QA` | SQL Server login username |
| `DB_USER_PW_QA` | SQL Server login password |
| `FIRST_UNDO_SCRIPT` | Earliest migration version to validate undo back to in the Build pipeline (e.g. `001`) |

The workflows map this one credential pair onto per-environment names (`DB_USER_BUILD`, `DB_USER_QA`, `DB_USER_CHECK`, `DB_USER_PROD`) in their `env:` block. They all point at the same secret here, but the separation means you only edit the right-hand side when adopting per-environment logins.

### 5. Configure local development (`flyway.user.toml`)

Create `flyway.user.toml` in the repo root - this file is gitignored and holds your local JDBC connections. Flyway Desktop uses this to connect to your dev and shadow environments.

```toml
[environments.development]
url = "jdbc:sqlserver://localhost;databaseName=DemoDB_Dev;integratedSecurity=true;trustServerCertificate=true"

[environments.shadow]
url = "jdbc:sqlserver://localhost;databaseName=DemoDB_Shadow;integratedSecurity=true;trustServerCertificate=true"
provisioner = "clean"

[environments.build]
url = "jdbc:sqlserver://localhost;databaseName=DemoDB_Build;trustServerCertificate=true"
user = "yourUser"
password = "yourPassword"
```

---

## Branch Strategy & CI/CD Pipelines

| Branch | Target | Workflow | Trigger |
|---|---|---|---|
| `Development` | Build DB (+ QA report) | `deploy-build.yml` | Push to `Development` |
| `QA` | QA DB | `deploy-qa.yml` | Push to `QA` |
| `Production` | PROD1 + PROD2 | `deploy-prod.yml` | Push to `Production` |

Each workflow has a commented-out `paths: - "migrations/**"` filter. Enable it to run deployments only when migration scripts change; leave it commented while testing workflow changes.

`Development` is the default branch and the base for all pull requests. Promotion is `Development -> QA -> Production` by pull request.

Every job follows the same shape:

```
Checkout -> Add Git Bash to PATH -> Setup Flyway -> Flyway action(s)
```

Steps within a job run strictly in order and stop on the first failure - there is no need for `needs:` between them. `needs:` only orders whole jobs.

### `deploy-build.yml` - Build validation

Runs on every push to `Development`. Validates the migration, its undo script, and produces the report reviewed on the pull request:

1. **Migrate Build** - `provision-mode: reprovision` runs the `clean` provisioner first, so this cleans and rebuilds the Build DB from scratch in one step.
2. **Rollback Build** - undoes back to `FIRST_UNDO_SCRIPT`, validating every undo script in between.
3. **Create QA Check Report** - code review, deployment changes, drift and dry run against QA. Uploaded as an artifact for PR review.

If the undo step fails, nothing is promoted to QA.

Drift checking and snapshots are deliberately **disabled** on the Build steps (`skip-drift-check: true`, `skip-snapshot: true`) - the Build DB is wiped every run, so drift against it is meaningless and would fail the job.

### `deploy-qa.yml` - QA deployment

Runs on push to `QA`. Applies pending migrations to the QA database. Drift check and snapshot are left at their defaults (enabled), so each QA deployment stores a snapshot - this is what makes the drift section of the build report meaningful on subsequent runs.

### `deploy-prod.yml` - Production deployment

Runs on push to `Production`. Three jobs:

1. **Generate Report** - code review, changes, drift and dry run against PROD2, using the Check database as the build environment. `fail-on-drift` and `fail-on-code-review` are `false` so the report never blocks a deployment.
2. **Deploy Prod 1** - `needs: flyway-report`.
3. **Deploy Prod 2** - `needs: flyway-report`, runs in parallel with Prod 1.

Both deploy jobs leave drift checking enabled. **Drift is fatal on deploy** - the action aborts with `Drift detected. Aborting deployment.` and does not write a new snapshot, so an out-of-band hotfix cannot be silently absorbed into the baseline.

> **Note:** GitHub Actions does not have a native manual approval gate. To add one, configure a [GitHub Environment](https://docs.github.com/en/actions/deployment/targeting-different-deployment-environments) with required reviewers and set `environment:` on the deploy jobs.

---

## Reports and Artifacts

With Option B the Flyway actions upload reports themselves - there is no `xcopy` or manual `upload-artifact` step.

| Workflow | Artifact | Contents |
|---|---|---|
| `deploy-build.yml` | `flyway-qa-pre-deployment-report` | HTML + JSON report, code review SARIF |
| `deploy-prod.yml` | `flyway-prod-pre-deployment-report` | HTML + JSON report, code review SARIF |
| `deploy-prod.yml` | `flyway-prod1/2-deployment-report` | Deployment result reports (only produced when the pre-deploy drift check generates a report) |

Download them from the **Artifacts** section of the workflow run, or via the links appended to the job summary. On disk the files are written to the runner workspace root, but they are transient - `clean: true` on checkout removes them at the start of every run.

Code review results are also pushed to **GitHub Code Scanning**, which requires this at the top of the workflow:

```yaml
permissions:
  contents: read
  security-events: write
```

Declaring a `permissions` block replaces the defaults, so `contents: read` must be listed for `actions/checkout` to keep working.

---

## Migration Naming Convention

```
V{version}_{timestamp}__{description}.sql       # Versioned migration
U{version}_{timestamp}__UNDO-{description}.sql  # Paired undo script
```

- Version numbers are zero-padded to three digits: `V001`, `V020`, etc.
- Timestamps use format `YYYYMMDDHHmmss`.
- The version number must match between the `V` and `U` pair (e.g. `V020` <-> `U020`).
- `validateMigrationNaming = true` is enforced - Flyway will reject scripts that don't match the pattern.

---

## Migration Script Conventions

Every migration script must begin with these SET statements (as generated by Flyway Desktop):

```sql
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
```

- Use `PRINT N'...'` statements to log progress within a script.
- Separate logical blocks with `GO`.
- Undo scripts must fully reverse the paired migration (drop added columns/objects, restore removed ones).
- Call `EXEC sp_refreshview` for any views affected by table changes.

---

## Running Flyway Locally

Run from the repo root. Connection details come from `flyway.user.toml`:

```cmd
:: Check pending migrations
flyway info -environment=development

:: Apply migrations
flyway migrate -environment=development

:: Roll back one version
flyway undo -environment=development

:: Validate undo scripts back to a target version
flyway undo -target=<version> -environment=build
```

---

## Key Flyway Settings (`flyway.toml`)

| Setting | Value | Purpose |
|---|---|---|
| `outOfOrder` | `true` | Migrations can be applied out of sequence (useful for parallel feature branches) |
| `mixed` | `true` | DDL and DML can coexist in a single script |
| `errorOverrides` | `S0001:0:I-` | Suppresses SQL Server informational messages that would otherwise fail the run |
| `validateMigrationNaming` | `true` | Rejects scripts that don't match the naming convention |
| `schemaModelLocation` | `schema-model` | Where Flyway Desktop keeps the declarative schema |
| `[flyway.check.code] failOnError` | `true` | Code review violations fail the pipeline |
| `provisioner = "clean"` | build / check / shadow | Database is wiped before use |
| `undoScripts = true` | Flyway Desktop | Automatically generates `U` scripts when generating migrations |

### Environments with empty URLs

`flyway.toml` is committed, so it must not contain connection details. Environments that exist only to carry a setting - such as a provisioner - are declared with an empty URL:

```toml
[environments.check]
provisioner = "clean"
url = ""

[environments.build]
url = ""
provisioner = "clean"
```

The real URL, user and password are supplied at runtime. The Flyway actions accept `target-environment` and `target-url` together and emit `-environment=build -environments.build.url=...`, so the runtime value wins.

### Allowing clean

Flyway disables `clean` by default. The Build workflow re-enables it **only for the Build environment**, from the workflow rather than the committed config:

```yaml
extra-args: -environments.build.flyway.cleanDisabled=false
```

The checks action does the equivalent for its build environment when `build-ok-to-erase: true` is set. QA and Production are never clean-enabled.

### Code review rules

Code review uses Flyway's built-in rule library. Custom SQLFluff rules live in `code-review-rules/`, which is gitignored and therefore not available to CI. If those rules are ever committed, re-add to `flyway.toml`:

```toml
[flyway.check]
sqlfluffCustomRulesPath = "code-review-rules"
rulesConfig = "code-review-rules/sqlfluff.cfg"
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `Duplicate table ... [environments.check]` | Flyway Desktop appended a second environment block to `flyway.toml` | Delete the duplicate block - TOML forbids repeated tables. Check after any Desktop rewrite |
| `/bin/bash: C:Projects...: No such file or directory` | `shell: bash` resolved to WSL bash | Add the *Add Git Bash to PATH* step (see above) |
| `Unable to execute clean as it has been disabled` | `cleanDisabled` defaults to `true` | Pass `-environments.<env>.flyway.cleanDisabled=false`, or set `build-ok-to-erase: true` on the checks action |
| `SQLFluff configuration file not found` | `code-review-rules/` is gitignored, so CI cannot see it | Use built-in rules, or commit the rules directory |
| `No snapshot located to use for drift analysis` | No deployment has stored a snapshot yet | Expected on first run - resolves once a deploy with `skip-snapshot: false` completes |
| Checks action falls back to Docker | Build database inputs were omitted | Always supply `build-url`, `build-user`, `build-password` |
