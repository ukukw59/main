---
name: candidate-raw-vault-profiling
description: "Use when profiling Snowflake tables for candidate Raw Vault models (stg_candidate, hub_candidate, sat_candidate); computes row counts, freshness, null rates, uniqueness, hashdiff quality, and schema drift using Snowflake MCP queries."
---

# Candidate Raw Vault Profiling

## Purpose

Profile Candidate Data Vault tables in Snowflake with a repeatable workflow using MCP tools and templated SQL.

## Use When

- You need quick health checks before or after a dbt run.
- You need per-environment validation across dev, qa, and prod schemas.
- You want a consistent profiling report for `stg_candidate`, `hub_candidate`, and `sat_candidate`.

## Expected Inputs

- `database`: default `SNOWFLAKE_LEARNING_DB`
- `source_schema`: where source table `CANDIDATE` exists (for example `PUBLIC_DEV`)
- `target_schema`: where dbt models were built (for example `RAW_VAULT_DEV`)
- `sample_limit`: optional, default `20`

## Workflow

1. Confirm source and target objects exist.
2. Run overview and freshness checks.
3. Run model-specific quality checks.
4. Capture top anomalies and attach actionable next steps.
5. Summarize pass or fail signals by table.

## Tool Plan

1. Use `mcp_snowflake_describe_table` for object metadata checks.
2. Use `mcp_snowflake_read_query` to execute templates in `templates/`.
3. Use `mcp_snowflake_append_insight` for important findings.

## Query Templates

Run the SQL files under `templates/` after replacing placeholders:

- `{{DATABASE}}`
- `{{SOURCE_SCHEMA}}`
- `{{TARGET_SCHEMA}}`
- `{{SAMPLE_LIMIT}}`

Templates included:

- `templates/00_overview_counts.sql`
- `templates/01_source_candidate_profile.sql`
- `templates/02_stg_candidate_profile.sql`
- `templates/03_hub_candidate_profile.sql`
- `templates/04_sat_candidate_profile.sql`
- `templates/05_cross_model_reconciliation.sql`
- `templates/06_7day_trend_profile.sql`

## Output Format

Return results in this order:

1. Environment context (`database`, `source_schema`, `target_schema`)
2. Table health summary (row count, null rate, duplicate risk, freshness)
3. Failed checks with metrics and impacted columns
4. Recommended fixes
5. Optional follow-up SQL to investigate

## Tailored Quality Rules

- `stg_candidate`: `EMPID`, `CANDIDATE_HK`, `CANDIDATE_HASHDIFF`, `LOAD_DATETIME`, and `RECORD_SOURCE` should be populated.
- `hub_candidate`: `CANDIDATE_HK` must be unique and `EMPID` must not be null.
- `sat_candidate`: each business state should produce consistent `CANDIDATE_HASHDIFF`; monitor duplicate active rows by `(CANDIDATE_HK, CANDIDATE_HASHDIFF)`.

## Example Invocation

Use this prompt in chat:

Profile candidate raw vault for database SNOWFLAKE_LEARNING_DB, source schema PUBLIC_DEV, target schema RAW_VAULT_DEV, sample limit 20.

Then execute templates in order and produce a summary with failing checks first.
