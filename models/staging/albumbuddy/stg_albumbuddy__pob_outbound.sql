/*
  stg_albumbuddy__pob_outbound
  ─────────────────────────────────────────────
  레거시 대응 : external.albumbuddy_pob_only
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('external', 'albumbuddy_pob_only') }}
