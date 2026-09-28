with orders as (
    select * from {{ ref('fact_orders') }}
    where order_status = 'delivered'
)

select
    order_date                                              as report_date,
    count(order_id)                                         as total_orders,
    count(distinct customer_key)                            as unique_customers,
    sum(items_revenue)                                      as gross_revenue,
    sum(items_freight)                                      as total_freight,
    sum(items_revenue - items_freight)                      as net_revenue,
    round(avg(items_total_value), 2)                        as avg_order_value,
    round(avg(delivery_days), 2)                            as avg_delivery_days,
    sum(case when is_delivered_on_time then 1 else 0 end)   as on_time_deliveries,
    round(
        sum(case when is_delivered_on_time then 1 else 0 end)::numeric
        / nullif(count(order_id), 0),
        4
    )                                                       as on_time_rate

from orders
group by order_date
