/*
  stg_mystarroom__user_group_definitions
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_auth_user_group
  grain       : 원천과 동일
  주의        : tb_auth_user_user_group(유저-그룹 매핑)은 stg_mystarroom__user_groups 다.
                이 모델은 그룹 마스터(정의) 자체다.
*/

select
    id,
    name,
    memo,
    grade,
    discount_info,
    is_active,
    company_id,
    b2b_partnership_information,
    connection_info_id,
    deposit,

    -- 메타는 맨 뒤
    created_at,
    updated_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_auth_user_group') }}
