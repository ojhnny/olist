-- Revenue can never be negative. This query should return zero rows.
select
    order_id,
    total_order_value
from {{ ref('mart_orders') }}
where total_order_value < 0