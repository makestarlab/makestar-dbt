/*
  int_orders_unioned
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 최종 UNION ALL
  grain       : 전 채널 주문 × 옵션
  
*/

-- 레거시 대응: pre_total_orders 의 최종 UNION ALL
with
    orders_commerce as (select * from {{ ref('int_orders_commerce') }}),
    orders_weidian as (select * from {{ ref('int_orders_weidian') }}),
    orders_offline as (select * from {{ ref('int_orders_offline') }}),
    orders_albumbuddy as (select * from {{ ref('int_orders_albumbuddy') }}),
    orders_manual_etc as (select * from {{ ref('int_orders_manual_etc') }}),
    manual__archived_orders as (select * from {{ ref('stg_manual__archived_orders') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('int_orders_commerce') }}
where false
