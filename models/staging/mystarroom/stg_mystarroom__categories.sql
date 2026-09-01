/*
  stg_mystarroom__categories
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_common_category
  grain       : 원천과 동일
*/

select
    id,
    name,
    is_active,
    translate,
    type,
    index,
    description,

    -- 메타는 맨 뒤
    datastream_metadata
from {{ source('mystarroom', 'tb_common_category') }}
