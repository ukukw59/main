-- 7-day trend profiling for row-count and freshness drift
-- Uses LOAD_DATETIME from stage, hub, and satellite models.

with stg_daily as (
  select
    date_trunc('day', LOAD_DATETIME) as run_date,
    count(*) as row_count,
    max(LOAD_DATETIME) as latest_load_ts
  from {{DATABASE}}.{{TARGET_SCHEMA}}.STG_CANDIDATE
  where LOAD_DATETIME >= dateadd(day, -7, current_timestamp())
  group by 1
),
hub_daily as (
  select
    date_trunc('day', LOAD_DATETIME) as run_date,
    count(*) as row_count,
    max(LOAD_DATETIME) as latest_load_ts
  from {{DATABASE}}.{{TARGET_SCHEMA}}.HUB_CANDIDATE
  where LOAD_DATETIME >= dateadd(day, -7, current_timestamp())
  group by 1
),
sat_daily as (
  select
    date_trunc('day', LOAD_DATETIME) as run_date,
    count(*) as row_count,
    max(LOAD_DATETIME) as latest_load_ts
  from {{DATABASE}}.{{TARGET_SCHEMA}}.SAT_CANDIDATE
  where LOAD_DATETIME >= dateadd(day, -7, current_timestamp())
  group by 1
),
combined as (
  select 'stg_candidate' as table_name, run_date, row_count, latest_load_ts from stg_daily
  union all
  select 'hub_candidate' as table_name, run_date, row_count, latest_load_ts from hub_daily
  union all
  select 'sat_candidate' as table_name, run_date, row_count, latest_load_ts from sat_daily
),
trend as (
  select
    table_name,
    run_date,
    row_count,
    lag(row_count) over (partition by table_name order by run_date) as prev_row_count,
    latest_load_ts,
    datediff('hour', latest_load_ts, current_timestamp()) as freshness_lag_hours
  from combined
)
select
  table_name,
  run_date,
  row_count,
  prev_row_count,
  (row_count - prev_row_count) as row_count_delta,
  round(100.0 * (row_count - prev_row_count) / nullif(prev_row_count, 0), 2) as row_count_delta_pct,
  latest_load_ts,
  freshness_lag_hours
from trend
order by table_name, run_date;

-- Optional alert-like view for large row-count drift or stale loads
select
  table_name,
  run_date,
  row_count,
  prev_row_count,
  (row_count - prev_row_count) as row_count_delta,
  round(100.0 * (row_count - prev_row_count) / nullif(prev_row_count, 0), 2) as row_count_delta_pct,
  freshness_lag_hours
from (
  select
    table_name,
    run_date,
    row_count,
    lag(row_count) over (partition by table_name order by run_date) as prev_row_count,
    datediff('hour', latest_load_ts, current_timestamp()) as freshness_lag_hours
  from combined
)
where abs(round(100.0 * (row_count - prev_row_count) / nullif(prev_row_count, 0), 2)) >= 20
   or freshness_lag_hours > 24
order by table_name, run_date;
