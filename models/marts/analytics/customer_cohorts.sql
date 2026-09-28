/*
  Monthly cohort retention analysis.
  Rows: one per (cohort_month, activity_month) pair.
  Shows how many customers from each acquisition cohort remained active month-over-month.
*/
with customer_cohorts as (
    select
        customer_unique_id,
        cohort_month
    from {{ ref('dim_customers') }}
    where cohort_month is not null
),

monthly_activity as (
    select
        c.customer_unique_id,
        c.cohort_month,
        date_trunc('month', o.ordered_at)::date     as activity_month,
        sum(o.items_total_value)                    as monthly_revenue
    from {{ ref('fact_orders') }} o
    join {{ ref('dim_customers') }} c using (customer_key)
    group by c.customer_unique_id, c.cohort_month, date_trunc('month', o.ordered_at)
),

cohort_sizes as (
    select cohort_month, count(distinct customer_unique_id) as cohort_size
    from customer_cohorts
    group by cohort_month
)

select
    ma.cohort_month,
    ma.activity_month,
    cs.cohort_size,
    count(distinct ma.customer_unique_id)                               as active_customers,
    round(
        count(distinct ma.customer_unique_id)::numeric / cs.cohort_size,
        4
    )                                                                   as retention_rate,
    extract(
        month from age(ma.activity_month::date, ma.cohort_month::date)
    )::int                                                              as months_since_acquisition,
    sum(ma.monthly_revenue)                                             as cohort_revenue

from monthly_activity ma
join cohort_sizes cs using (cohort_month)
group by ma.cohort_month, ma.activity_month, cs.cohort_size
