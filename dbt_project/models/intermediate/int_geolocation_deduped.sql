with geo as (
    select * from {{ ref('stg_geolocation') }}
),

deduped as (

    select
        geolocation_zip_code_prefix,
        avg(geolocation_lat)    as geolocation_lat,
        avg(geolocation_lng)    as geolocation_lng,
        mode(geolocation_city)  as geolocation_city,
        mode(geolocation_state) as geolocation_state
    from geo

    group by geolocation_zip_code_prefix

)

select * from deduped


-- stg_geolocation can have many rows for the same 
-- geolocation_zip_code_prefix (same ZIP, slightly different lat/lng/city/state)