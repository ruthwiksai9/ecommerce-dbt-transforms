with source as (
    select * from {{ source('raw', 'sellers') }}
),

renamed as (
    select
        seller_id,
        lpad(seller_zip_code_prefix::text, 5, '0')  as zip_code_prefix,
        lower(trim(seller_city))                     as city,
        upper(trim(seller_state))                    as state
    from source
    where seller_id is not null
)

select * from renamed
