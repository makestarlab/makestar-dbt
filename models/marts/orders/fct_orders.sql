/*
  fct_orders
  ─────────────────────────────────────────────
  레거시 대응 : datamart.total_orders
  grain       : 주문 × 옵션 1건
  
*/

{{ config(materialized='table') }}

-- ┌─────────────────────────────────────────────────────────────┐
-- │ Phase 1: 레거시 래퍼. 지표 정의를 먼저 고정하기 위한 임시 구현. │
-- │ Phase 2: 아래 from 절을 int_orders_overridden 으로 교체.       │
-- │          tests/assert_orders_parity.sql 로 행 단위 대조.       │
-- └─────────────────────────────────────────────────────────────┘

select
    'commerce' as service_code,
    {{ dbt_utils.generate_surrogate_key(["'commerce'", 'user_id']) }} as user_sk,
    *
from {{ source('dw_legacy', 'total_orders') }}

-- Phase 2 교체본:
-- select
--     'commerce' as service_code,
--     {{ dbt_utils.generate_surrogate_key(["'commerce'", 'user_id']) }} as user_sk,
--     market_type_final as market_type,
--     biz_type_final    as biz_type,
--     ...
-- from {{ ref('int_orders_overridden') }}
-- where market_type_final != '제외'
