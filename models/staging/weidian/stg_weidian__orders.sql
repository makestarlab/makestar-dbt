/*
  stg_weidian__orders
  -----------------------------------------------
  레거시 대응 : external.WEIDIAN_ORDER_HIS
  grain       : 원천과 동일
  주의        : refundStatus 만 원본에서 camelCase 라 refund_status 로 리네임한다.
*/

select
    order_id,
    status,
    refundStatus as refund_status,
    time,
    update_time,
    buyer_name,
    total,
    express_type,
    express_no,
    express_fee
from {{ source('external', 'WEIDIAN_ORDER_HIS') }}
