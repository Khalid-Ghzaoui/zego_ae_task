-- Q2: monthly GWP (gross written premium) for 2025 to date by vehicle type, missing motnhs as zero.
-- Every month x vehicle type combination is generated first and GWP is attached to it, so combinations with no transactions show 0 instead of disappearing. 

with months as (

    select month_start_date
    from {{ ref('dim_month') }}
    where month_start_date >= date '2025-01-01'
        and month_start_date <= date_trunc('month', current_date)
), 

vehicle_types as (

    select distinct vehicle_type
    from {{ ref('dim_product') }}
), 

monthly_gwp as (

    select 
        date_trunc('month', fct.accounting_date) as month_start_date, 
        dim_product.vehicle_type, 
        sum(fct.transaction_gwp) as gwp
    
    from {{ ref('fct_policy_transaction') }} as fct 
    -- Join scope: many transactions to one product. Each transaction's own product is used, so GWP follows the vehicle insured at the time
    inner join {{ ref('dim_product') }} as dim_product
        on fct.product_id = dim_product.product_id
    where fct.accounting_date >= date '2025-01-01'
    group by 1, 2
)

select 
    months.month_start_date, 
    vehicle_types.vehicle_type, 
    coalesce(monthly_gwp.gwp, 0) as gwp 
from months 
cross join vehicle_types 
left join monthly_gwp
    on monthly_gwp.month_start_date = months.month_start_date
    and monthly_gwp.vehicle_type = vehicle_types.vehicle_type
order by 1, 2