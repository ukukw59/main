-- Overview row counts and freshness across source and raw vault models
select 'source_candidate' as table_name,
       count(*) as row_count,
       cast(null as timestamp_ntz) as max_load_datetime
from {{DATABASE}}.{{SOURCE_SCHEMA}}.CANDIDATE
union all
select 'stg_candidate' as table_name,
       count(*) as row_count,
       max(LOAD_DATETIME) as max_load_datetime
from {{DATABASE}}.{{TARGET_SCHEMA}}.STG_CANDIDATE
union all
select 'hub_candidate' as table_name,
       count(*) as row_count,
       max(LOAD_DATETIME) as max_load_datetime
from {{DATABASE}}.{{TARGET_SCHEMA}}.HUB_CANDIDATE
union all
select 'sat_candidate' as table_name,
       count(*) as row_count,
       max(LOAD_DATETIME) as max_load_datetime
from {{DATABASE}}.{{TARGET_SCHEMA}}.SAT_CANDIDATE
order by table_name;
