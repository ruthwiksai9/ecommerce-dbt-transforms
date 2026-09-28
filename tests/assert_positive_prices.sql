-- Singular test: no negative prices in order items
select order_id, product_id, price
from {{ ref('stg_order_items') }}
where price < 0
