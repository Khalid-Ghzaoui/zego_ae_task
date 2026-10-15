-- Grain: one row per user (policyholder)

select
    cast(user_id as integer) as user_id, 
    given_names, 
    last_names, 
    address_1, 
    address_2, 
    city, 
    postcode, 
    country

from {{ ref('raw_user') }}