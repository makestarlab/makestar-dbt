/*
  fct_orders
  -----------------------------------------------
  레거시 대응 : datamart.total_orders
  grain       : 주문 x 옵션 1건

  Phase 1: 레거시 래퍼. 지표 정의를 먼저 고정하기 위한 임시 구현.
  Phase 2: 아래 from 절을 int_orders_overridden 으로 교체하고
           tests/assert_orders_parity_*.sql 로 행 단위 대조.
*/

{{ config(materialized='table') }}

select
    'commerce' as service_code,
    {{ dbt_utils.generate_surrogate_key(["'commerce'", 'user_id']) }} as user_sk,
    *
from {{ source('dw_legacy', 'total_orders') }}