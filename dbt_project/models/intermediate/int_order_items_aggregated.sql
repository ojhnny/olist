with items as (
 -- find the table called order_items in the staging schema
    select * from {{ ref('stg_order_items') }}

),

aggregated as (
    -- aggregate the data
    select
        order_id,
        count(*)                   as item_count,
        count(distinct product_id) as distinct_product_count,
        count(distinct seller_id)  as distinct_seller_count,
        sum(price)                 as total_item_price,
        sum(freight_value)         as total_freight_value,
        sum(price + freight_value) as total_order_value

    from items

    group by order_id

)

select * from aggregated

--  convert a fan-out table (order_items) into an order-level summary that's easier 
-- to join into final marts without duplicating rows.  