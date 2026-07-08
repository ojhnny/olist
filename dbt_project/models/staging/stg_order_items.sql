with source as (
    -- find the table called order_items in the raw schema
    select * from {{ source('raw', 'order_items') }}

),

renamed as (

    select
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        cast(price as decimal(10,2))         as price,
        cast(freight_value as decimal(10,2)) as freight_value

    from source

)

select * from renamed

-- For money, use decimal because it's exact; double is approximate.