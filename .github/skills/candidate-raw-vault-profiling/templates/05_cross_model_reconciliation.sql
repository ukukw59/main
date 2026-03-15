-- Cross-model reconciliation checks for candidate raw vault
with src as (
  select count(*) as row_count,
         count(distinct EMPID) as distinct_empid
  from {{DATABASE}}.{{SOURCE_SCHEMA}}.CANDIDATE
),
stg as (
  select count(*) as row_count,
         count(distinct EMPID) as distinct_empid,
         count(distinct CANDIDATE_HK) as distinct_hk
  from {{DATABASE}}.{{TARGET_SCHEMA}}.STG_CANDIDATE
),
hub as (
  select count(*) as row_count,
         count(distinct EMPID) as distinct_empid,
         count(distinct CANDIDATE_HK) as distinct_hk
  from {{DATABASE}}.{{TARGET_SCHEMA}}.HUB_CANDIDATE
),
sat as (
  select count(*) as row_count,
         count(distinct CANDIDATE_HK) as distinct_hk,
         count(distinct CANDIDATE_HASHDIFF) as distinct_hashdiff
  from {{DATABASE}}.{{TARGET_SCHEMA}}.SAT_CANDIDATE
)
select
  src.row_count as src_rows,
  stg.row_count as stg_rows,
  hub.row_count as hub_rows,
  sat.row_count as sat_rows,
  src.distinct_empid as src_distinct_empid,
  stg.distinct_empid as stg_distinct_empid,
  hub.distinct_empid as hub_distinct_empid,
  stg.distinct_hk as stg_distinct_hk,
  hub.distinct_hk as hub_distinct_hk,
  sat.distinct_hk as sat_distinct_hk,
  sat.distinct_hashdiff as sat_distinct_hashdiff
from src, stg, hub, sat;

-- Stage records that did not land in hub by hash key (should be empty)
select s.CANDIDATE_HK,
       s.EMPID,
       s.LOAD_DATETIME
from {{DATABASE}}.{{TARGET_SCHEMA}}.STG_CANDIDATE s
left join {{DATABASE}}.{{TARGET_SCHEMA}}.HUB_CANDIDATE h
  on s.CANDIDATE_HK = h.CANDIDATE_HK
where h.CANDIDATE_HK is null
limit {{SAMPLE_LIMIT}};

-- Hub keys with no satellite row (can happen if satellite load failed)
select h.CANDIDATE_HK,
       h.EMPID,
       h.LOAD_DATETIME
from {{DATABASE}}.{{TARGET_SCHEMA}}.HUB_CANDIDATE h
left join {{DATABASE}}.{{TARGET_SCHEMA}}.SAT_CANDIDATE s
  on h.CANDIDATE_HK = s.CANDIDATE_HK
where s.CANDIDATE_HK is null
limit {{SAMPLE_LIMIT}};
