-- policy_total_gwp is taken once per policy. That is only valid if every
-- row of a policy carries the same value. Returns policies where it doesn't

select inception_policy_id
from {{ ref('stg_policy_transaction') }}
group by 1
having count(distinct policy_total_gwp) > 1