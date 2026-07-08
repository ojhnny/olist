with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

items as (
    select * from {{ ref('int_order_items_aggregated') }}
),

payments as (
    select * from {{ ref('int_order_payments_aggregated') }}
),

reviews as (
    select * from {{ ref('int_order_reviews_aggregated') }}
),

final as (

    select
        o.order_id,
        c.customer_unique_id,                          -- the REAL customer
        o.customer_id,                                 -- order-scoped id (keep for tracing)
        c.customer_state,
        c.customer_city,

        o.order_status,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        coalesce(i.item_count, 0)          as item_count,
        coalesce(i.total_item_price, 0)    as total_item_price,
        coalesce(i.total_freight_value, 0) as total_freight_value,
        coalesce(i.total_order_value, 0)   as total_order_value,

        coalesce(p.total_payment_value, 0) as total_payment_value,
        p.max_installments,

        r.avg_review_score,
        r.review_count

    from orders o
    left join customers c on o.customer_id = c.customer_id
    left join items i     on o.order_id = i.order_id
    left join payments p  on o.order_id = p.order_id
    left join reviews r   on o.order_id = r.order_id

)

select * from final