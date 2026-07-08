with products as (

    select * from {{ ref('stg_products') }}

),

translation as (

    select * from {{ ref('stg_product_category_translation') }}

),

joined as (

    select
        p.product_id,
        p.product_category_name,
        coalesce(t.product_category_name_english, 'unknown') as product_category,
        p.product_weight_g,
        p.product_photos_qty,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm

    from products p
    left join translation t
        on p.product_category_name = t.product_category_name

    -- some products have a NULL category, and a couple of Portuguese categories 
    -- are missing from the translation file entirely

)

select * from joined