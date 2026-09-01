/*
  stg_mystarroom__artists
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_artist_artist
  grain       : 원천과 동일
*/

select
    id,
    artist_type,
    published_at,
    homepage,
    site_info,
    profile_image_id,
    name,
    company_id,
    introduction,
    nickname,
    index,
    i18n_name,
    is_displayed,
    logo_image_id,
    brand_idx,
    is_active,
    fandom_name,
    i18n_artist_description,

    -- 메타는 맨 뒤
    created_at,
    updated_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_artist_artist') }}
