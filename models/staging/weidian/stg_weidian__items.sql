/*
  stg_weidian__items
  -----------------------------------------------
  레거시 대응 : external.WEIDIAN_ITEM
  grain       : 원천과 동일
*/

select
    product_id,
    product_name,
    product_merchant_code,
    product_desc,
    product_price,
    option_id,
    option_name,
    option_merchant_code,
    option_price,

    -- 메타는 맨 뒤
    created_at,
    updated_at
from {{ source('external', 'WEIDIAN_ITEM') }}
