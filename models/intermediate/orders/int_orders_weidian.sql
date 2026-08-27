/*
  int_orders_weidian
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 external CTE
  grain       : 웨이디엔 주문 × 옵션
  
*/

-- 레거시 대응: pre_total_orders 의 external CTE
with
    weidian__orders as (select * from {{ ref('stg_weidian__orders') }}),
    weidian__order_items as (select * from {{ ref('stg_weidian__order_items') }}),
    weidian__items as (select * from {{ ref('stg_weidian__items') }}),
    exchange_rates_unioned as (select * from {{ ref('int_exchange_rates_unioned') }}),
    catalog_items as (select * from {{ ref('int_catalog_items') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('stg_weidian__orders') }}
where false
