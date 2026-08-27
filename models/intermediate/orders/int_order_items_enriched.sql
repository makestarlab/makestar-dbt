/*
  int_order_items_enriched
  ─────────────────────────────────────────────
  레거시 대응 : datamart.vw_commerce_order_items
  grain       : 주문 × 아이템
  
*/

-- 레거시 대응: datamart.vw_commerce_order_items
with
    mystarroom__order_items as (select * from {{ ref('stg_mystarroom__order_items') }}),
    mystarroom__product_options as (select * from {{ ref('stg_mystarroom__product_options') }}),
    mystarroom__product_event_data as (select * from {{ ref('stg_mystarroom__product_event_data') }}),
    mystarroom__additional_orders as (select * from {{ ref('stg_mystarroom__additional_orders') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('stg_mystarroom__order_items') }}
where false
