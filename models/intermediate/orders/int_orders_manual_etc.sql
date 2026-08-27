/*
  int_orders_manual_etc
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 etc CTE
  grain       : 수기 주문
  
*/

-- 레거시 대응: pre_total_orders 의 etc CTE
with
    manual__extra_orders as (select * from {{ ref('stg_manual__extra_orders') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('stg_manual__extra_orders') }}
where false
