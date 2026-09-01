/*
  bridge_order_event
  -----------------------------------------------
  레거시 대응 : pre_commerce_orders 의 string_agg(event_id, ', ')
  grain       : 주문 × 옵션 × event_id
*/

-- 레거시는 옵션 하나에 이벤트 특전이 여러 개일 때 event_id 를 콤마로 결합한다.
-- ("EV1, EV2") → 이벤트별 분석 시 split 하면 팬아웃. M:N 은 브릿지로 푼다.
-- int_orders_shopping 의 matched CTE 와 동일한 조인/필터를, 콤마 결합 전 단계에서 노출한다.
with
    orders_enriched as (select * from {{ ref('int_orders_enriched') }}),
    order_items_enriched as (select * from {{ ref('int_order_items_enriched') }}),
    catalog_event_resolution as (select * from {{ ref('int_catalog_event_resolution') }})

select distinct
    o.order_id as order_no,
    oi.product_option_id,
    ec.event_id
from orders_enriched o
join order_items_enriched oi on o.order_id = oi.order_id and o.order_number = oi.order_number
join catalog_event_resolution ec
    on oi.product_event_id = ec.product_event_id
    and oi.product_option_id = ec.product_option_id
where (o.payment_status in ('CONFIRMED', 'PARTIAL_CANCELED') or o.order_status = 'PAYMENT_PROCESSING')
  and o.order_status in ('PAYMENT_PROCESSING', 'PAYMENT_COMPLETED', 'INVENTORY_CHECKING', 'SHIPPING_PROCESSING', 'COMPLETED')
  and oi.product_event_type in ('쇼핑')
