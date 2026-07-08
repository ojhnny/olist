with source as (
    -- find the table called orders in the raw schema
    select * from {{ source('raw', 'orders') }}

),

renamed as (
    -- rename the columns to match the desired output       
    select
        order_id,
        customer_id,
        lower(trim(order_status)) as order_status,

        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date

    from source

)

select * from renamed