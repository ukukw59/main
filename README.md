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
*** Add File: C:\Users\Geetha\main\profiles.yml
my_new_project:
  target: dev
  outputs:
	 dev:
		type: snowflake
		account: VHCWREG-YM73012
		user: UMAN
		password: "Ashvath08$GGeethA86$"
		role:
		database: SNOWFLAKE_LEARNING_DB
		warehouse: COMPUTE_WH
		schema: PUBLIC
		threads: 4
		client_session_keep_alive: false
