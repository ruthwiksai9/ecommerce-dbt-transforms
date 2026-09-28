with source as (
    select * from {{ source('raw', 'order_items') }}
),

renamed as (
    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date::timestamp          as shipping_limit_at,
        price::numeric(10, 2)                   as price,
        freight_value::numeric(10, 2)           as freight_value,

        -- derived
        (price::numeric + freight_value::numeric)           as total_item_value,
        round(
            freight_value::numeric
            / nullif(price::numeric + freight_value::numeric, 0),
            4
        )                                                   as freight_ratio

    from source
    where order_id is not null
      and product_id is not null
      and price::numeric >= 0
)

select * from renamed
