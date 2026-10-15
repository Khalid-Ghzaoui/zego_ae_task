-- Grain: one row per policyholder

select
    user_id,
    given_names,
    last_names,
    city,
    postcode,
    country
    
from {{ ref('stg_user') }}
