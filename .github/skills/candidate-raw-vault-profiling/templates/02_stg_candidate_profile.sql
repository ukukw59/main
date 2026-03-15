-- Staging model profiling for STG_CANDIDATE
with base as (
  select *
  from {{DATABASE}}.{{TARGET_SCHEMA}}.STG_CANDIDATE
)
select
  count(*) as total_rows,
  count_if(EMPID is null) as null_empid_rows,
  count_if(CANDIDATE_HK is null) as null_candidate_hk_rows,
  count_if(CANDIDATE_HASHDIFF is null) as null_hashdiff_rows,
  count_if(LOAD_DATETIME is null) as null_load_datetime_rows,
  count_if(RECORD_SOURCE is null) as null_record_source_rows,
  count(distinct EMPID) as distinct_empid,
  count(distinct CANDIDATE_HK) as distinct_candidate_hk,
  count(distinct CANDIDATE_HASHDIFF) as distinct_hashdiff
from base;

-- Collision check: one CANDIDATE_HK mapping to multiple EMPID values
select CANDIDATE_HK,
       count(distinct EMPID) as distinct_empid_per_hk
from {{DATABASE}}.{{TARGET_SCHEMA}}.STG_CANDIDATE
group by CANDIDATE_HK
having count(distinct EMPID) > 1
order by distinct_empid_per_hk desc
limit {{SAMPLE_LIMIT}};

-- Business key duplication check in stage
select EMPID,
       count(*) as cnt
from {{DATABASE}}.{{TARGET_SCHEMA}}.STG_CANDIDATE
group by EMPID
having count(*) > 1
order by cnt desc, EMPID
limit {{SAMPLE_LIMIT}};
