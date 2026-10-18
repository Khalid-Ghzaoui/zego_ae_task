-- fct_policy takes a policy's owner, product and start date from its first transaction. 
-- That is only valid if the first transaction actually opens the policy
-- Returns policies whose first transaction is anything else (e.g., an incomplete history that starts with an adjustment)

with first_transaction as (
    select 
        inception_policy_id, 
        transaction_type_id
    from {{ ref('stg_policy_transaction') }}
    qualify row_number() over (partition by inception_policy_id order by change_number, transaction_sk) = 1
)

select first_transaction.inception_policy_id
from first_transaction
inner join {{ ref('dim_transaction_type')}} as dim_transaction_type
    on first_transaction.transaction_type_id = dim_transaction_type.transaction_type_id
where dim_transaction_type.transaction_type_description not in ('new_policy', 'renewal')
