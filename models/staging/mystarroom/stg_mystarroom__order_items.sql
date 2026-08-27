/*
  stg_mystarroom__order_items
  -----------------------------------------------
  레거시 대응 : datamart.vw_commerce_order_items
  grain       : 주문 x 옵션 (소스와 1:1)
  주의        : 소스가 이미 평탄화되어 있어 UNNEST 가 필요 없다.
                (order_id, order_number, product_option_id) 기준 210행 중복 존재.
*/

select
    id                          as source_row_id,
    order_id,
    order_number,
    is_event_join,
    product_event_id,
    product_event_code,
    product_event_type,
    product_id,
    product_code,
    company_id,
    product_option_id,
    product_option_pay_quantity,
    product_option_pay_amount,
    updated_at
from {{ source('dw_legacy', 'tb_commerce_orders_flattened') }}
