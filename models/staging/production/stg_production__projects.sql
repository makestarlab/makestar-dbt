/*
  stg_production__projects
  ─────────────────────────────────────────────
  레거시 대응 : production.project
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('production', 'project') }}
