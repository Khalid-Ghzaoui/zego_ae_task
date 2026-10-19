-- Grain: one row per policy transaction (transaction_sk)
-- Answers Q3 (previous_transaction_was_mta) and Q4 (tax_rate)

with transactions as (

    select * from {{ ref('stg_policy_transaction') }}

), 

transaction_types as (

    select * from {{ ref('dim_transaction_type') }}

), 

-- Join scope: many transactions to one transaction type 
-- Left join so a missing type surfaces as a failed test rather than silently dropping GWP (gross written premium). Row count is tested to equal stg_policy_transaction
joined as (

    select 
        transactions.*, 
        transaction_types.is_mid_term_adjustment, 
        transaction_types.is_cancellation, 
        -- Cancellations are reported on effective_end_date, which represents the cancellation date. All other transaction types are reported on effective_start_date.
        case when is_cancellation then effective_end_date else effective_start_date end as accounting_date

    from transactions 
    left join transaction_types 
        on transactions.transaction_type_id = transaction_types.transaction_type_id

), 

final as (

    select 
        transaction_sk,
        user_id,
        inception_policy_id,
        adjustment_policy_id,
        product_id,
        transaction_type_id,
        change_number,
        effective_start_date,
        effective_end_date,
        accounting_date,
        transaction_gwp,
        premium_amount,
        tax_amount,
        total_amount,

        -- Q4: tax is charged on premium. Null when premium is zero
        round(tax_amount / nullif(premium_amount, 0), 4) as tax_rate, 

        -- Q3: was the previous transaction on this policy a mid-term adjustment? 
        -- Ordered by change_number, not dates: a cancellation's start date is the original policy date, so date ordering would misplace it. 
        -- transaction_sk breaks any remaining tie so the result is deterministic. The first transaction has no previous one, so it is false
        coalesce(
            lag(is_mid_term_adjustment) over(partition by inception_policy_id order by change_number), 
                false
        ) as previous_transaction_was_mta

from joined

)

select * from final