-- Satellite model profiling for SAT_CANDIDATE
with base as (
  select *
  from {{DATABASE}}.{{TARGET_SCHEMA}}.SAT_CANDIDATE
)
select
  count(*) as total_rows,
  count_if(CANDIDATE_HK is null) as null_candidate_hk_rows,
  count_if(CANDIDATE_HASHDIFF is null) as null_hashdiff_rows,
  count_if(EMPNAME is null) as null_empname_rows,
  count_if(EMPLOCATION is null) as null_emplocation_rows,
  count_if(LOAD_DATETIME is null) as null_load_datetime_rows,
  count_if(EFFECTIVE_FROM is null) as null_effective_from_rows,
  count(distinct CANDIDATE_HK) as distinct_candidate_hk,
  count(distinct CANDIDATE_HASHDIFF) as distinct_hashdiff,
  min(LOAD_DATETIME) as min_load_datetime,
  max(LOAD_DATETIME) as max_load_datetime
from base;

-- Duplicate version records per HK and hashdiff (potential duplicate loads)
select CANDIDATE_HK,
       CANDIDATE_HASHDIFF,
       count(*) as cnt
from {{DATABASE}}.{{TARGET_SCHEMA}}.SAT_CANDIDATE
group by CANDIDATE_HK, CANDIDATE_HASHDIFF
having count(*) > 1
order by cnt desc, CANDIDATE_HK
limit {{SAMPLE_LIMIT}};

-- High churn keys: many versions per candidate key
select CANDIDATE_HK,
       count(*) as version_count,
       count(distinct CANDIDATE_HASHDIFF) as distinct_versions
from {{DATABASE}}.{{TARGET_SCHEMA}}.SAT_CANDIDATE
group by CANDIDATE_HK
having count(*) > 5
order by version_count desc
limit {{SAMPLE_LIMIT}};
