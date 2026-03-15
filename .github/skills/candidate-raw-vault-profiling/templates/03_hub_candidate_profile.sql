-- Hub model profiling for HUB_CANDIDATE
with base as (
  select *
  from {{DATABASE}}.{{TARGET_SCHEMA}}.HUB_CANDIDATE
)
select
  count(*) as total_rows,
  count_if(CANDIDATE_HK is null) as null_candidate_hk_rows,
  count_if(EMPID is null) as null_empid_rows,
  count(distinct CANDIDATE_HK) as distinct_candidate_hk,
  count(distinct EMPID) as distinct_empid,
  (count(*) - count(distinct CANDIDATE_HK)) as duplicate_candidate_hk_rows,
  (count(*) - count(distinct EMPID)) as duplicate_empid_rows,
  min(LOAD_DATETIME) as min_load_datetime,
  max(LOAD_DATETIME) as max_load_datetime
from base;

-- Duplicate hash key details (should be empty)
select CANDIDATE_HK,
       count(*) as cnt
from {{DATABASE}}.{{TARGET_SCHEMA}}.HUB_CANDIDATE
group by CANDIDATE_HK
having count(*) > 1
order by cnt desc, CANDIDATE_HK
limit {{SAMPLE_LIMIT}};
