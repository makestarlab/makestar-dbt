/*
  int_orders_enriched
  ─────────────────────────────────────────────
  레거시 대응 : datamart.vw_commerce_orders
  grain       : 주문 1건
  
*/

-- 레거시 대응: datamart.vw_commerce_orders
with
    mystarroom__orders as (select * from {{ ref('stg_mystarroom__orders') }}),
    mystarroom__users as (select * from {{ ref('stg_mystarroom__users') }}),
    mystarroom__user_groups as (select * from {{ ref('stg_mystarroom__user_groups') }}),
    production__country_codes as (select * from {{ ref('stg_production__country_codes') }}),
    exchange_rates_unioned as (select * from {{ ref('int_exchange_rates_unioned') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('stg_mystarroom__orders') }}
where false
