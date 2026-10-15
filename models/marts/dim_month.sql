-- Grain: one row per calendar month
-- A complete list of months, so BI tools can show months with no transactions as zero instead of dropping them (Q2)
-- Starts Jan 2024 to cover the earliest transaction in the data (Nov 2024). In prod the start would be derived from source

with spine as (

    {{ dbt_utils.date_spine(
        datepart="month", 
        start_date="cast('2024-01-01' as date)", 
        end_date="cast(date_trunc('month', current_date) + interval 1 month as date)"
    ) }}
)

select 
    cast(date_month as date)        as month_start_date, 
    extract(year from date_month)   as calendar_year, 
    extract(month from date_month)  as calendar_month

from spine