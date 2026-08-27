/*
  int_orders_shopping
  ─────────────────────────────────────────────
  레거시 대응 : pre_commerce_orders 2번 UNION (쇼핑)
  grain       : 주문 × 옵션
  위험        : ⚠️ string_agg(event_id) 제거
*/

-- 레거시 대응: pre_commerce_orders 2번 UNION (쇼핑)
with
    orders_enriched as (select * from {{ ref('int_orders_enriched') }}),
    order_items_enriched as (select * from {{ ref('int_order_items_enriched') }}),
    catalog_items as (select * from {{ ref('int_catalog_items') }}),
    catalog_event_resolution as (select * from {{ ref('int_catalog_event_resolution') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('int_orders_enriched') }}
where false
