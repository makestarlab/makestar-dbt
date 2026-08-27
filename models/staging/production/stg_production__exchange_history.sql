/*
  stg_production__exchange_history
  ─────────────────────────────────────────────
  레거시 대응 : production.country_exchange_history
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('production', 'country_exchange_history') }}
