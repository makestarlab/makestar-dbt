/*
  stg_albumbuddy__pob_outbound
  -----------------------------------------------
  레거시 대응 : external.albumbuddy_pob_only
  grain       : 원천과 동일
  주의        : date 는 BigQuery 함수명과 겹치므로 outbound_date 로 리네임한다.
*/

select
    type,
    stock_type,
    date as outbound_date,
    product_name,
    quantity,
    price,
    currency,
    total,
    memo,
    order_id,
    history_created_at
from {{ source('external', 'albumbuddy_pob_only') }}
