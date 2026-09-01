/*
  stg_mystarroom__artist_companies
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_artist_company
  grain       : 원천과 동일
*/

select
    id,
    name,
    company_code,
    i18n_name,
    creator_idx_list,
    company_role_list,

    -- 메타는 맨 뒤
    created_at,
    updated_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_artist_company') }}
