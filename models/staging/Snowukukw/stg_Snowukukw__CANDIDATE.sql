with 

source as (

    select * from {{ source('Snowukukw', 'CANDIDATE') }}

),

renamed as (

    select
        empid,
        empname,
        emplocation

    from source

)

select * from renamed