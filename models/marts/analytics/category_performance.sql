with order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select product_id, category_name from {{ ref('dim_products') }}
),

orders as (
    select order_id, order_date
    from {{ ref('fact_orders') }}
    where order_status = 'delivered'
),

aggregated as (
    select
        date_trunc('month', o.order_date)::date             as report_month,
        p.category_name,
        count(distinct oi.order_id)                         as total_orders,
        count(oi.order_item_id)                             as units_sold,
        round(sum(oi.price), 2)                             as gross_revenue,
        round(sum(oi.freight_value), 2)                     as total_freight,
        round(avg(oi.price), 2)                             as avg_unit_price,
        round(avg(oi.freight_ratio), 4)                     as avg_freight_ratio

    from order_items oi
    join products p using (product_id)
    join orders o using (order_id)
    group by date_trunc('month', o.order_date), p.category_name
)

select
    *,
    round(
        gross_revenue
        / nullif(sum(gross_revenue) over (partition by report_month), 0),
        4
    )                                                       as revenue_share_pct
from aggregated
