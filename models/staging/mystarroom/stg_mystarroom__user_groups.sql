/*
  stg_mystarroom__user_groups
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_auth_user_user_group
  grain       : 원천과 동일
*/

select
    id,
    role,
    group_id,
    user_id,

    -- 메타는 맨 뒤
    created_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_auth_user_user_group') }}
