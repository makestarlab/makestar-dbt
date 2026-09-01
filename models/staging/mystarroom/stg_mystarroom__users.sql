/*
  stg_mystarroom__users
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_auth_user
  grain       : 원천과 동일
*/

select
    id,
    password,
    last_login,
    email,
    is_admin,
    is_active,
    is_certified,
    is_superuser,
    user_idx,
    is_withdrawn,
    is_operator,
    user_type,
    created_from,
    withdrawn_at,
    has_group,

    -- 메타는 맨 뒤
    created_at,
    updated_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_auth_user') }}
