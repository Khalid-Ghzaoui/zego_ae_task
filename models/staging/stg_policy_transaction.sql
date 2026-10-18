-- Grain: one row per policy transaction
-- The source has no transaction id, so transaction_sk is built from the columns that together identify a transaction, and tested for uniqueness.

with source as (
    
    select * from {{ ref('raw_policy_transaction') }} 
), 

renamed as (

    select 
        {{ dbt_utils.generate_surrogate_key([
            'inception_policy_id',
            'adjustment_policy_id',
            'change_number',
            'transaction_type_id'
]) }}                                                as transaction_sk, 

        cast(user_id as integer)                     as user_id,
        cast(inception_policy_id as integer)         as inception_policy_id,
        cast(adjustment_policy_id as integer)        as adjustment_policy_id,
        cast(product_id as integer)                  as product_id,
        cast(change_number as integer)               as change_number,
        cast(transaction_type_id as integer)         as transaction_type_id,
        cast(effective_start_date as date)           as effective_start_date,
        cast(effective_end_date as date)             as effective_end_date,
        cast(transaction_gwp as decimal(10, 2))      as transaction_gwp,
        cast(policy_total_gwp as decimal(10, 2))     as policy_total_gwp,
        -- Unpack the transaction_breakdown JSON.
        cast(json_extract_string(transaction_breakdown, '$.transaction.premium') as decimal(10, 2)) as premium_amount,
        cast(json_extract_string(transaction_breakdown, '$.transaction.tax')     as decimal(10, 2)) as tax_amount,
        cast(json_extract_string(transaction_breakdown, '$.transaction.total')   as decimal(10, 2)) as total_amount

    from source
)

select * from renamed