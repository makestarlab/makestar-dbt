/*
  stg_albumbuddy__package_deliveries
  ─────────────────────────────────────────────
  레거시 대응 : public.package_delivery
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('albumbuddy', 'package_delivery') }}
