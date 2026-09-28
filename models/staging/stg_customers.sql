with source as (
    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        customer_id,
        customer_unique_id,
        lpad(customer_zip_code_prefix::text, 5, '0')    as zip_code_prefix,
        lower(trim(customer_city))                      as city,
        upper(trim(customer_state))                     as state
    from source
    where customer_id is not null
      and customer_unique_id is not null
)

select * from renamed
