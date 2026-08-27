/*
  stg_mystarroom__user_groups
  ─────────────────────────────────────────────
  레거시 대응 : pg_mystarroom_public.tb_auth_user_user_group
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('mystarroom', 'tb_auth_user_user_group') }}
