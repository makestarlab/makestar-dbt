/*
  stg_weidian__order_items
  -----------------------------------------------
  레거시 대응 : external.WEIDIAN_ORDER_ITEM_HIS
  grain       : 원천과 동일
*/

select
    order_id,
    product_id,
    product_name,
    product_merchant_code,
    option_id,
    option_name,
    option_merchant_code,
    price,
    quantity,
    total_price,
    refund_total_price,
    refund_product_price,
    refund_express_price
from {{ source('external', 'WEIDIAN_ORDER_ITEM_HIS') }}
