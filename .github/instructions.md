# Copilot Instructions for DemoDB

## Overview

This repo demonstrates a **Flyway Enterprise + GitHub Actions** pipeline for automating SQL Server database deployments across Build, QA, and Production environments. It is intended as a working reference for teams looking to adopt database DevOps with Flyway Desktop and self-hosted GitHub Actions runners.

All schema changes are applied through versioned migration scripts. There is no application code.

---

## Prerequisites

Before setting up this pipeline you will need:

- **Flyway Enterprise license** — a token and registered email from [Redgate](https://www.red-gate.com/products/flyway/enterprise/). The `flyway` CLI must be installed on the self-hosted runner.
- **Flyway Desktop** (optional, recommended for local development) — used to generate versioned migration scripts and keep `schema-model/` in sync.
- **Self-hosted GitHub Actions runner** — a Windows machine registered to this repository. The runner must have the `flyway` CLI on its PATH. See [GitHub docs](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners) for setup instructions.
- **SQL Server instances** — at minimum: Build, QA, and Production databases. A separate clean Check database is required for the Production drift/change report.
- **SQL Server Authentication enabled** — workflows authenticate with a username and password. In SSMS go to *Server Properties → Security* and set **SQL Server and Windows Authentication mode**.

---

## Repository Structure

```
migrations/          # Versioned (V) and undo (U) migration scripts — applied in order
schema-model/        # Declarative schema snapshot maintained by Flyway Desktop — do not hand-edit
flyway.toml          # Shared project config (committed) — environments, comparison options, filters
flyway.user.toml     # Local user config (not committed) — JDBC URLs for dev/shadow environments
Filter.scpf          # Redgate SQL Compare filter — controls which objects are included in comparisons
.github/workflows/   # CI/CD pipeline definitions
```

---

## Getting Started

### 1. Fork or clone this repository

Use this repo as a starting point. Replace the contents of `migrations/` and `schema-model/` with your own database schema.

### 2. Register a self-hosted runner

In your GitHub repository go to **Settings → Actions → Runners → New self-hosted runner** and follow the instructions for Windows. The runner must have the `flyway` CLI available on its PATH.

### 3. Configure GitHub Actions Variables

Go to **Settings → Secrets and variables → Actions → Variables** and create the following:

| Variable | Description |
|---|---|
| `USER_EMAIL` | Email address associated with your Flyway Enterprise license |
| `JDBC_BUILD` | JDBC connection string for the Build database |
| `JDBC_QA` | JDBC connection string for the QA database |
| `JDBC_PROD1` | JDBC connection string for Production database 1 |
| `JDBC_PROD2` | JDBC connection string for Production database 2 |
| `JDBC_CHECK` | JDBC connection string for the Check database (clean DB used for drift reports) |
| `DB_NAME_PROD_2` | Database name for Prod 2 — used to name the HTML check report artifact |

JDBC connection string format:
```
jdbc:sqlserver://<host>;databaseName=<db>;trustServerCertificate=true
```

### 4. Configure GitHub Actions Secrets

Go to **Settings → Secrets and variables → Actions → Secrets** and create the following:

| Secret | Description |
|---|---|
| `FLYWAY_TOKEN` | Flyway Enterprise license token |
| `DB_USER_NAME_QA` | SQL Server login username (used for QA and Production) |
| `DB_USER_PW_QA` | SQL Server login password (used for QA and Production) |
| `FIRST_UNDO_SCRIPT` | Earliest migration version to validate undo back to in the Build pipeline (e.g. `001`) |

### 5. Configure local development (`flyway.user.toml`)

Create `flyway.user.toml` in the repo root — this file is gitignored and holds your local JDBC connections. Flyway Desktop uses this to connect to your dev and shadow environments.

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
| `Development` | Build DB | `deploy-build.yml` | Push to `Development` with changes in `migrations/` |
| `QA` | QA DB | `deploy-qa.yml` | Push to `QA` with changes in `migrations/` |
| `Production` | PROD1 + PROD2 | `deploy-prod.yml` | Push to `Production` |

### `deploy-build.yml` — Build validation

Runs on every push to `Development`. This pipeline validates both the migration and its undo script before anything reaches QA:

1. **Clean** the Build DB (wipes all objects)
2. **Migrate** — applies all pending migrations from scratch
3. **Undo** — rolls back to `FIRST_UNDO_SCRIPT`, validating every undo script in between

If the undo step fails, the migration is blocked from promoting to QA.

### `deploy-qa.yml` — QA deployment

Runs on push to `QA`. Runs `flyway info migrate info` against the QA database — applies pending migrations and prints pre/post state.

### `deploy-prod.yml` — Production deployment

Runs on push to `Production`. Three jobs run in sequence:

1. **Generate Report** (`flyway check`) — produces an HTML drift and change report comparing the pending migrations against the current Production state. Published as a GitHub Actions artifact.
2. **Deploy Prod 1** — runs `flyway migrate` against PROD1 (depends on report job completing).
3. **Deploy Prod 2** — runs `flyway info migrate info` against PROD2, runs in parallel with Prod 1.

> **Note:** GitHub Actions does not have a native manual approval gate. To add one, configure a [GitHub Environment](https://docs.github.com/en/actions/deployment/targeting-different-deployment-environments) with required reviewers and set `environment:` on the deploy jobs.

---

## Migration Naming Convention

```
V{version}_{timestamp}__{description}.sql       # Versioned migration
U{version}_{timestamp}__UNDO-{description}.sql  # Paired undo script
```

- Version numbers are zero-padded to three digits: `V001`, `V020`, etc.
- Timestamps use format `YYYYMMDDHHmmss`.
- The version number must match between the `V` and `U` pair (e.g. `V020` ↔ `U020`).
- `validateMigrationNaming = true` is enforced — Flyway will reject scripts that don't match the pattern.

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
| `baselineOnMigrate` | `true` | Used in all pipeline commands — baselines existing DBs on first run |
| `-errorOverrides=S0001:0:I-` | (pipeline flag) | Suppresses specific SQL Server informational errors that would otherwise fail the run |
| `provisioner = "clean"` | shadow env | Shadow database is wiped on each Flyway Desktop operation |
| `undoScripts = true` | Flyway Desktop | Automatically generates `U` scripts when generating migrations |
