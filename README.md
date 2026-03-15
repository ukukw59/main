Welcome to your new dbt project!

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

### Candidate Raw Vault flow

This repo now includes an AutomateDV example for the `SNOWFLAKE_LEARNING_DB.PUBLIC.CANDIDATE` stage table.

1. Connect Git to dbt Cloud:
	- In dbt Cloud, open Account Settings -> Integrations.
	- Connect your Git provider and authorize the repository that backs this workspace.
	- In dbt Cloud, point the project to the repo and choose the branch you want to develop on.
2. Install packages locally:
	- Run `dbt deps --profiles-dir .`.
3. Build the stage model:
	- `models/staging/stg_candidate.sql`
4. Build the Raw Vault models:
	- `models/raw_vault/hub_candidate.sql`
	- `models/raw_vault/sat_candidate.sql`
5. Run the models:
	- `dbt run --profiles-dir . --select stg_candidate hub_candidate sat_candidate`
6. Test the models:
	- `dbt test --profiles-dir . --select hub_candidate sat_candidate`

The generated hub uses `EMPID` as the business key. The satellite stores `EMPNAME` and `EMPLOCATION` as descriptive attributes.

The local profile for this repo is stored in `profiles.yml`, so include `--profiles-dir .` when running dbt from this workspace.

### Run same models in multiple schemas with GitHub Actions

This repository includes a workflow at `.github/workflows/dbt-multi-env.yml` with:

- one matrix job for `dev` and `qa`
- one separate `prod` job (`deploy-prod`)

- dev: source schema `PUBLIC_DEV`, target schema `RAW_VAULT_DEV`
- qa: source schema `PUBLIC_QA`, target schema `RAW_VAULT_QA`
- prod: source schema `PUBLIC_PROD`, target schema `RAW_VAULT_PROD`

Required secrets (set per environment):

- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`
- `SNOWFLAKE_PASSWORD`
- `SNOWFLAKE_ROLE`

Set up environments, separate credentials, and approval gates:

1. Open the GitHub repository.
2. Go to Settings -> Environments.
3. Create environment `dev`.
4. Create environment `qa`.
5. Create environment `prod`.
6. Open `dev` -> Environment secrets -> Add the 4 Snowflake secrets for dev.
7. Open `qa` -> Environment secrets -> Add the 4 Snowflake secrets for qa.
8. Open `prod` -> Environment secrets -> Add the 4 Snowflake secrets for prod.
9. For approval gates, in each environment configure Required reviewers.
10. For `prod`, configure Deployment branches to only protected branches.

How this works in workflow:

- `run-dev-qa` matrix job uses `environment: ${{ matrix.github_environment }}`.
- `dev` matrix run reads secrets from the `dev` environment.
- `qa` matrix run reads secrets from the `qa` environment.
- `deploy-prod` job uses `environment: prod`.
- `deploy-prod` reads secrets from the `prod` environment.
- If required reviewers are configured, the job pauses until approval.

Prod strict controls in this workflow:

- Prod is in a separate `deploy-prod` job.
- Dev and QA run immediately on `push` and on manual dispatch.
- Prod does not run on `push`.
- Prod runs only on `workflow_dispatch` when input `include_prod=true`.
- Prod also requires `github.ref_protected == true`.

How configuration is injected:

- `profiles.yml` reads credentials and target settings from environment variables.
- `models/sources.yml` reads the source database/schema from environment variables.
- The workflow matrix sets `DBT_TARGET`, `DBT_SOURCE_SCHEMA`, and `DBT_TARGET_SCHEMA` for each environment.

Run manually from GitHub:

1. Open Actions.
2. Select `dbt raw vault multi env`.
3. Click `Run workflow`.

### Data profiling skill for Candidate Raw Vault

A ready-to-use profiling skill is available at:

- `.github/skills/candidate-raw-vault-profiling/SKILL.md`

SQL templates are available at:

- `.github/skills/candidate-raw-vault-profiling/templates/00_overview_counts.sql`
- `.github/skills/candidate-raw-vault-profiling/templates/01_source_candidate_profile.sql`
- `.github/skills/candidate-raw-vault-profiling/templates/02_stg_candidate_profile.sql`
- `.github/skills/candidate-raw-vault-profiling/templates/03_hub_candidate_profile.sql`
- `.github/skills/candidate-raw-vault-profiling/templates/04_sat_candidate_profile.sql`
- `.github/skills/candidate-raw-vault-profiling/templates/05_cross_model_reconciliation.sql`
- `.github/skills/candidate-raw-vault-profiling/templates/06_7day_trend_profile.sql`

How to use:

1. In Copilot Chat, request profiling for `database`, `source_schema`, and `target_schema`.
2. Run templates in numeric order after replacing placeholders:
	- `{{DATABASE}}`
	- `{{SOURCE_SCHEMA}}`
	- `{{TARGET_SCHEMA}}`
	- `{{SAMPLE_LIMIT}}`
3. Review failed checks first, then reconcile stage, hub, and satellite counts.
