-- Grain: one row per policy (inception_policy_id)
-- Built from fct_policy_transaction so policy totals and transaction totals can never disagree. Answers Q1

with transactions as (

    select * from {{ ref('fct_policy_transaction') }}

), 

-- The transaction that opened the policy (new policy or renewal) defines its owner, the product it was sold as, and its start date
policy_openings as (
    
    select
        inception_policy_id, 
        user_id, 
        product_id, 
        effective_start_date as policy_start_date, 
    from transactions 
    qualify row_number() over (partition by inception_policy_id order by change_number, transaction_sk) = 1
), 

policy_totals as (

    select 
        inception_policy_id, 
        sum(transaction_gwp) as net_gwp, 
        sum(total_amount)    as net_total_amount
    from transactions
    group by 1
), 

-- policy_total_gwp is repeated on every row of a policy in the source, so it is taken once per policy and never summed. Used only to reconcile net_gwp (net gross written premium)
reported_totals as ( 

    select 
        inception_policy_id, 
        max(policy_total_gwp) as reported_policy_total_gwp
    from {{ ref('stg_policy_transaction') }}
    group by 1
)

-- Join scope: all three CTEs have exactly one row per policy, so these are one-to-one joins. Uniqueness of inception_policy_id is tested
select
    policy_openings.inception_policy_id,
    policy_openings.user_id,
    policy_openings.product_id,
    policy_openings.policy_start_date,
    policy_totals.net_gwp,
    policy_totals.net_total_amount,
    reported_totals.reported_policy_total_gwp

from policy_openings
left join policy_totals
    on policy_openings.inception_policy_id = policy_totals.inception_policy_id
left join reported_totals
    on policy_openings.inception_policy_id = reported_totals.inception_policy_id