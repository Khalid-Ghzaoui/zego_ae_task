-- Grain: one row per transaction type.

select
    cast(transaction_type_id as integer) as transaction_type_id,
    transaction_type_description,
    cast(is_adjustment as boolean) as is_adjustment
from {{ ref('raw_transaction_type') }}