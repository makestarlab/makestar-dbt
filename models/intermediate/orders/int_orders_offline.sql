/*
  int_orders_offline
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 offline CTE (매장)
  grain       : 매장 주문
  
*/

-- 레거시 대응: pre_total_orders 의 offline CTE (매장)
with
    manual__offline_orders as (select * from {{ ref('stg_manual__offline_orders') }}),
    exchange_rates_unioned as (select * from {{ ref('int_exchange_rates_unioned') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('stg_manual__offline_orders') }}
where false
