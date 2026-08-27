-- Phase 2 전환 검증: 월별 총매출이 레거시와 0.01% 이내로 일치하는지
{% set tol = 0.0001 %}

with new_ as (
    select date_trunc(date(pay_date), month) as m, sum(total_revenue) as rev
    from {{ ref('fct_orders') }} group by 1
),
old_ as (
    select date_trunc(date(pay_date), month) as m, sum(total_revenue) as rev
    from {{ source('dw_legacy', 'total_orders') }} group by 1
)
select n.m, n.rev as new_rev, o.rev as old_rev,
       safe_divide(abs(n.rev - o.rev), nullif(o.rev, 0)) as diff_pct
from new_ n
join old_ o using (m)
where safe_divide(abs(n.rev - o.rev), nullif(o.rev, 0)) > {{ tol }}
