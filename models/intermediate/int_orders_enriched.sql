/*
  Enriches orders with payment totals and item counts.
  Ephemeral — compiled into downstream models, not materialized.
*/
with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items_agg as (
    select
        order_id,
        count(*)                        as total_items,
        sum(price)                      as items_revenue,
        sum(freight_value)              as items_freight,
        sum(total_item_value)           as items_total_value,
        avg(freight_ratio)              as avg_freight_ratio,
        count(distinct seller_id)       as distinct_sellers
    from {{ ref('stg_order_items') }}
    group by order_id
),

payments_agg as (
    select
        order_id,
        sum(payment_value)              as total_payment_value,
        count(distinct payment_type)    as payment_methods,
        bool_or(is_installment_payment) as has_installments,
        max(installments)               as max_installments
    from {{ ref('stg_order_payments') }}
    group by order_id
)

select
    o.*,
    coalesce(i.total_items, 0)          as total_items,
    coalesce(i.items_revenue, 0)        as items_revenue,
    coalesce(i.items_freight, 0)        as items_freight,
    coalesce(i.items_total_value, 0)    as items_total_value,
    i.avg_freight_ratio,
    coalesce(i.distinct_sellers, 0)     as distinct_sellers,
    coalesce(p.total_payment_value, 0)  as total_payment_value,
    coalesce(p.payment_methods, 0)      as payment_methods,
    coalesce(p.has_installments, false) as has_installments,
    coalesce(p.max_installments, 1)     as max_installments,

    -- delivery duration in days
    case
        when o.delivered_at is not null and o.ordered_at is not null
        then extract(epoch from (o.delivered_at - o.ordered_at)) / 86400.0
    end                                 as delivery_days

from orders o
left join order_items_agg i using (order_id)
left join payments_agg p using (order_id)
