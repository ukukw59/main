-- Source profiling for raw candidate table
with base as (
  select *
  from {{DATABASE}}.{{SOURCE_SCHEMA}}.CANDIDATE
)
select
  count(*) as total_rows,
  count_if(EMPID is null) as null_empid_rows,
  round(100.0 * count_if(EMPID is null) / nullif(count(*), 0), 2) as null_empid_pct,
  count(distinct EMPID) as distinct_empid,
  (count(*) - count(distinct EMPID)) as duplicate_empid_rows,
  count_if(trim(coalesce(EMPNAME, '')) = '') as blank_empname_rows,
  count_if(trim(coalesce(EMPLOCATION, '')) = '') as blank_emplocation_rows
from base;

-- Optional sample of duplicate EMPID values
select EMPID,
       count(*) as cnt
from {{DATABASE}}.{{SOURCE_SCHEMA}}.CANDIDATE
group by EMPID
having count(*) > 1
order by cnt desc, EMPID
limit {{SAMPLE_LIMIT}};
