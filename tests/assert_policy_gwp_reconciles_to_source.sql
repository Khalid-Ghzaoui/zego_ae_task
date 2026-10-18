-- Our net GWP (sum of transaction_gwp per policy) must equal the source's reported policy_total_gwp. Returns the policies that disagree. 
-- "is distinct from" also flags a null on either side; "<>" would let it pass.
-- Zero rows returned = pass

select 
    inception_policy_id, 
    net_gwp, 
    reported_policy_total_gwp
from {{ ref('fct_policy') }}
where net_gwp is distinct from reported_policy_total_gwp