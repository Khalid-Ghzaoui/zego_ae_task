-- Q1: number of users who purchased at least one fixed policy with total transaction value > 0.
-- "Total transaction value" = premium + tax across all of the policy's transactions, net of refunds (fct_policy.net_total_amount).
-- Assumption: total transaction value > 0 means the net value of the policy after all transactions, not "the customer ever had a positive transaction"
-- e.g., +600 new policy, -600 refund = 0 net value, so this policy would not count. A naive query looking for any postive transaction would count it.

select 
    count(distinct fct_policy.user_id) as users_with_fixed_policy

from {{ ref('fct_policy') }} as fct_policy 
-- Join scope: many policies to one product
inner join {{ ref('dim_product') }} as dim_product
    on fct_policy.product_id = dim_product.product_id
where dim_product.product_type = 'fixed'
    and fct_policy.net_total_amount > 0