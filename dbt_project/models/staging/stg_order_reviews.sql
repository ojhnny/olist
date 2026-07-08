with source as (
    -- find the table called order_reviews in the raw schema

    select * from {{ source('raw', 'order_reviews') }}

),

renamed as (
    -- rename the columns to match the desired output   
    select
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp

    from source

)

select * from renamed

-- keep nullable free-text columns mostly untouched except maybe light normalization if needed