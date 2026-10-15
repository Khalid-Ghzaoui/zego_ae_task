-- Grain: one row per transaction type.
-- The facts use these flags instead of hard-coded ids, so each definition lives in one place.

select
    transaction_type_id,
    transaction_type_description,
    is_adjustment,
    transaction_type_description = 'mid_term_adjustment' as is_mid_term_adjustment,
    transaction_type_description = 'cancellation'        as is_cancellation
    
from {{ ref('stg_transaction_type') }}