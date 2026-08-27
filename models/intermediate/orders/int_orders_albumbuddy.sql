/*
  int_orders_albumbuddy
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 albumbuddy 블록
  grain       : 앨범버디 주문
  
*/

-- 레거시 대응: pre_total_orders 의 albumbuddy 블록
with
    albumbuddy__orders as (select * from {{ ref('stg_albumbuddy__orders') }}),
    albumbuddy__package_deliveries as (select * from {{ ref('stg_albumbuddy__package_deliveries') }}),
    albumbuddy__pob_outbound as (select * from {{ ref('stg_albumbuddy__pob_outbound') }}),
    exchange_rates_unioned as (select * from {{ ref('int_exchange_rates_unioned') }})
select
    -- TODO: 레거시 SELECT 절 이식
    cast(null as string) as placeholder
from {{ ref('stg_albumbuddy__orders') }}
where false
