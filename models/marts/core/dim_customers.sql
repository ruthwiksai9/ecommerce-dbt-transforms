with customers as (
    select * from {{ ref('stg_customers') }}
),

order_history as (
    select
        customer_unique_id,
        min(ordered_at)                 as first_order_at,
        max(ordered_at)                 as last_order_at,
        count(distinct order_id)        as lifetime_orders,
        date_trunc('month', min(ordered_at))::date as cohort_month
    from {{ ref('stg_orders') }} o
    join {{ ref('stg_customers') }} c using (customer_id)
    group by customer_unique_id
)

select
    {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }}    as customer_key,
    c.customer_id,
    c.customer_unique_id,
    c.zip_code_prefix,
    c.city,
    c.state,
    h.first_order_at,
    h.last_order_at,
    h.lifetime_orders,
    h.cohort_month,
    case
        when h.lifetime_orders = 1 then 'one_time'
        when h.lifetime_orders between 2 and 3 then 'repeat'
        else 'loyal'
    end                                                          as customer_segment
from customers c
left join order_history h using (customer_unique_id)
