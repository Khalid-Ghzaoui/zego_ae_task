-- Q3: flag whether the previous transaction on the same policy was a mid-term adjustment. The flag is built into fct_policy_transaction
-- (previous_transaction_was_mta), so BI users get it without re-deriving it.
-- Expected on the sample data: true only for policy 1001 change 2 policy 6001 change 2

select 
    fct.inception_policy_id, 
    fct.change_number, 
    dim_transaction_type.transaction_type_description,
    fct.accounting_date,
    fct.previous_transaction_was_mta
from {{ ref('fct_policy_transaction')}} as fct 
-- Join scope: many transactions to one transaction type
inner join {{ ref('dim_transaction_type') }} as dim_transaction_type
    on fct.transaction_type_id = dim_transaction_type.transaction_type_id
order by 1, 2