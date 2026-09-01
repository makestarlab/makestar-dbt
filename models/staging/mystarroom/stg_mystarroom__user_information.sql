/*
  stg_mystarroom__user_information
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_auth_user_information
  grain       : 원천과 동일
*/

select
    id,
    birth,
    user_id,
    nickname,
    profile_image_id,
    is_agreed_marketing,
    is_agreed_updated_notification,
    phone,
    real_name,
    agreed_marketing_services,
    available_services,
    country_code,
    gender_type,

    -- 메타는 맨 뒤
    created_at,
    updated_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_auth_user_information') }}
