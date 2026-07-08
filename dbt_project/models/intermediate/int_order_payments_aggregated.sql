with payments as (

    select * from {{ ref('stg_order_payments') }}

),

aggregated as (

    select
        order_id,
        count(*)                  as payment_count,
        sum(payment_value)        as total_payment_value,
        max(payment_installments) as max_installments

    from payments

    group by order_id

)

select * from aggregated