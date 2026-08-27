/*
  int_orders_reward
  ─────────────────────────────────────────────
  레거시 대응 : pre_commerce_orders 1번 UNION (이벤트/펀딩)
  grain       : 주문 × 옵션
  
*/

-- 레거시 대응: pre_commerce_orders 1번 UNION (이벤트/펀딩)
with
    orders_enriched as (select * from {{ ref('int_orders_enriched') }}),
    order_items_enriched as (select * from {{ ref('int_order_items_enriched') }}),
    catalog_items as (select * from {{ ref('int_catalog_items') }}),
    catalog_option_sales as (select * from {{ ref('int_catalog_option_sales') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('int_orders_enriched') }}
where false
