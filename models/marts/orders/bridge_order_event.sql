/*
  bridge_order_event
  ─────────────────────────────────────────────
  레거시 대응 : pre_commerce_orders 의 string_agg(event_id, ', ')
  grain       : 주문 × 옵션 × event_id
  
*/

-- 레거시는 옵션 하나에 이벤트 특전이 여러 개일 때 event_id 를 콤마로 결합한다.
-- ("EV1, EV2") → 이벤트별 분석 시 split 하면 팬아웃. M:N 은 브릿지로 푼다.
select
    order_no,
    product_option_id,
    event_id
from {{ ref('int_catalog_event_resolution') }}
where false  -- TODO
