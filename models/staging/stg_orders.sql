with source as (
    select * from {{ source('raw', 'orders') }}
),

renamed as (
    select
        order_id,
        customer_id,
        lower(trim(order_status))                           as order_status,
        order_purchase_timestamp::timestamp                 as ordered_at,
        order_approved_at::timestamp                        as approved_at,
        order_delivered_carrier_date::timestamp             as shipped_at,
        order_delivered_customer_date::timestamp            as delivered_at,
        order_estimated_delivery_date::timestamp            as estimated_delivery_at,

        -- derived delivery metrics
        case
            when order_delivered_customer_date is not null
                and order_estimated_delivery_date is not null
            then order_delivered_customer_date::timestamp
                    <= order_estimated_delivery_date::timestamp
        end                                                 as is_delivered_on_time,

        date_trunc('day', order_purchase_timestamp)::date   as order_date,
        date_part('year', order_purchase_timestamp)::int    as order_year,
        date_part('month', order_purchase_timestamp)::int   as order_month,
        date_part('dow', order_purchase_timestamp)::int     as order_day_of_week,
        date_part('hour', order_purchase_timestamp)::int    as order_hour

    from source
    where order_id is not null
      and customer_id is not null
)

select * from renamed
