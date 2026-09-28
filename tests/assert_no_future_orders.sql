-- Singular test: no orders with purchase timestamp in the future
select order_id, ordered_at
from {{ ref('stg_orders') }}
where ordered_at > current_timestamp
