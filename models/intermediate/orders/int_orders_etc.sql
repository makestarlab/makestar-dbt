/*
  int_orders_etc
  ─────────────────────────────────────────────
  레거시 대응 : pre_commerce_orders 3번 UNION (차액지불)
  grain       : 주문 × 옵션
  
*/

-- 레거시 대응: pre_commerce_orders 3번 UNION (차액지불)
with
    orders_enriched as (select * from {{ ref('int_orders_enriched') }}),
    order_items_enriched as (select * from {{ ref('int_order_items_enriched') }}),
    mystarroom__users as (select * from {{ ref('stg_mystarroom__users') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('int_orders_enriched') }}
where false
