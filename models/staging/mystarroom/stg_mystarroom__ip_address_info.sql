/*
  stg_mystarroom__ip_address_info
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_common_ip_address_info
  grain       : 원천과 동일
*/

select
    id,
    ip_address,
    ip_description,

    -- 메타는 맨 뒤
    datastream_metadata
from {{ source('mystarroom', 'tb_common_ip_address_info') }}
