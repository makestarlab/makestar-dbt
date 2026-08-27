/*
  stg_weidian__orders
  ─────────────────────────────────────────────
  레거시 대응 : external.WEIDIAN_ORDER_HIS
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('external', 'WEIDIAN_ORDER_HIS') }}
