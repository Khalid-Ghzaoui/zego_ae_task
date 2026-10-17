-- Q4: tax rate paid on each transaction = tax / premium.
-- Built into fct_policy_transaction (tax_rate). Null when premium is zero. 
-- Expected on the sample data: 0.12 on every transaction, null for policy 5001

select 
    inception_policy_id, 
    change_number, 
    premium_amount, 
    tax_amount, 
    tax_rate
from {{ ref('fct_policy_transaction') }}
order by 1, 2