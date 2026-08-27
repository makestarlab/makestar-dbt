/*
  int_orders_commerce
  ─────────────────────────────────────────────
  레거시 대응 : datamart.pre_commerce_orders
  grain       : 주문 × 옵션
  
*/

-- 레거시 대응: datamart.pre_commerce_orders
with
    orders_reward as (select * from {{ ref('int_orders_reward') }}),
    orders_shopping as (select * from {{ ref('int_orders_shopping') }}),
    orders_etc as (select * from {{ ref('int_orders_etc') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('int_orders_reward') }}
where false
