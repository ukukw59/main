{{ config(materialized='view') }}

with source as (

    select *
    from {{ source('raw', 'candidate') }}

),

renamed as (

    select
        empid as EMPID,
        empname as EMPNAME,
        emplocation as EMPLOCATION,
        {{ automate_dv.hash(columns=['empid'], alias='CANDIDATE_HK') }},
        {{ automate_dv.hash(columns=['empname', 'emplocation'], alias='CANDIDATE_HASHDIFF', is_hashdiff=true) }},
        cast(current_timestamp() as timestamp_ntz) as LOAD_DATETIME,
        cast(current_timestamp() as timestamp_ntz) as EFFECTIVE_FROM,
        'RAW_CANDIDATE_FILE' as RECORD_SOURCE

    from source

)

select * from renamed