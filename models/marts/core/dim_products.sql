with products as (
    select * from {{ ref('stg_products') }}
),

sales_history as (
    select
        product_id,
        count(distinct order_id)    as times_ordered,
        sum(price)                  as lifetime_revenue,
        avg(price)                  as avg_selling_price,
        min(price)                  as min_price,
        max(price)                  as max_price
    from {{ ref('stg_order_items') }}
    group by product_id
)

select
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }}     as product_key,
    p.product_id,
    p.category_name,
    p.weight_g,
    p.volume_cm3,
    p.photos_qty,
    p.name_length,
    p.description_length,
    coalesce(s.times_ordered, 0)                                 as times_ordered,
    coalesce(s.lifetime_revenue, 0)                              as lifetime_revenue,
    s.avg_selling_price,
    s.min_price,
    s.max_price,

    -- product tier based on order volume
    case
        when coalesce(s.times_ordered, 0) = 0 then 'inactive'
        when s.times_ordered <= 5 then 'low'
        when s.times_ordered <= 20 then 'medium'
        else 'high'
    end                                                          as demand_tier

from products p
left join sales_history s using (product_id)
