-- Singular test: delivered_at must be after ordered_at
select order_id, ordered_at, delivered_at
from {{ ref('stg_orders') }}
where delivered_at is not null
  and delivered_at < ordered_at
