with orders as (
    select * from {{ ref('int_orders_enriched') }}
),

customers as (
    select customer_id, customer_key from {{ ref('dim_customers') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['o.order_id']) }}   as order_key,
    o.order_id,
    c.customer_key,
    o.order_status,
    o.ordered_at,
    o.approved_at,
    o.shipped_at,
    o.delivered_at,
    o.estimated_delivery_at,
    o.order_date,
    o.order_year,
    o.order_month,
    o.order_day_of_week,
    o.order_hour,
    o.is_delivered_on_time,
    o.total_items,
    o.items_revenue,
    o.items_freight,
    o.items_total_value,
    o.avg_freight_ratio,
    o.distinct_sellers,
    o.total_payment_value,
    o.payment_methods,
    o.has_installments,
    o.max_installments,
    o.delivery_days,
    current_timestamp                                        as dbt_updated_at

from orders o
left join customers c using (customer_id)
