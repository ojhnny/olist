with source as (
    -- find the table called customers in the raw schema
    select * from {{ source('raw', 'customers') }}
),

renamed as (
     -- rename the columns to match the desired output
    select
        customer_id,
        customer_unique_id,
        -- cast the customer_zip_code_prefix to a varchar
        cast(customer_zip_code_prefix as varchar) as customer_zip_code_prefix,
        -- lower the customer_city and trim the whitespace
        lower(trim(customer_city))               as customer_city,
        -- upper the customer_state and trim the whitespace
        upper(trim(customer_state))              as customer_state

    from source
    -- select all the columns from the source
)

select * from renamed
-- select all the columns from the renamed table