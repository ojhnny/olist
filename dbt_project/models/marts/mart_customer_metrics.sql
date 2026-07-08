with orders as (

    select *
    from {{ ref('mart_orders') }}
    where order_status = 'delivered'          -- realized purchases only

),

snapshot as (
    -- find the most recent order purchase timestamp
    select max(order_purchase_timestamp) as snapshot_date from orders
),

-- rfm metrics
customer_metrics as (

    select
        customer_unique_id,

        min(order_purchase_timestamp) as first_order_date,
        max(order_purchase_timestamp) as last_order_date,

        count(distinct order_id)      as frequency,
        sum(total_order_value)        as monetary,
        avg(total_order_value)        as avg_order_value,
        avg(avg_review_score)         as avg_review_score,
        max(customer_state)           as customer_state

    from orders
    group by customer_unique_id

),

final as (

    select
        cm.*,
        date_diff('day', cm.last_order_date, s.snapshot_date) as recency_days
    from customer_metrics cm
    cross join snapshot s

)

select * from final