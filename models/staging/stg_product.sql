-- Grain: one row per product
-- product code is country_vertical_type; split it so BI users can filter on product_type and vehicle_type directly instead of string matching

select
    cast(product_id as integer)          as product_id,
    product_code,
    split_part(product_code, '_', 1)     as country_code,
    split_part(product_code, '_', 2)     as vertical,
    split_part(product_code, '_', 3)     as product_type,
    split_part(product_code, '_', 4)     as vehicle_type,
    cast(is_billed_upfront as boolean)   as is_billed_upfront
    
from {{ ref('raw_product') }}