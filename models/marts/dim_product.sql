-- Grain: one row per product
-- BI users filter on product_type and vehicle_type directly

select
    product_id,
    product_code,
    country_code,
    vertical,
    product_type,
    vehicle_type,
    is_billed_upfront
    
from {{ ref('stg_product') }}