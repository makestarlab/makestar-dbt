/*
  stg_production__country_codes
  ─────────────────────────────────────────────
  레거시 대응 : production.SPM_COUNTRY_CODE
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('production', 'SPM_COUNTRY_CODE') }}
