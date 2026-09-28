with source as (
    select * from {{ source('raw', 'products') }}
),

renamed as (
    select
        product_id,
        coalesce(lower(trim(product_category_name)), 'unknown')     as category_name,
        product_name_lenght                                         as name_length,
        product_description_lenght                                  as description_length,
        product_photos_qty                                          as photos_qty,
        product_weight_g::numeric                                   as weight_g,
        product_length_cm::numeric                                  as length_cm,
        product_height_cm::numeric                                  as height_cm,
        product_width_cm::numeric                                   as width_cm,

        -- derived volume
        round(
            product_length_cm::numeric
            * product_height_cm::numeric
            * product_width_cm::numeric,
            2
        )                                                           as volume_cm3

    from source
    where product_id is not null
)

select * from renamed
