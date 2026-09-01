/*
  stg_manual__albumbuddy_internal
  -----------------------------------------------
  레거시 대응 : datamart.albumbuddy_internal
  grain       : 유저 1건
*/

select user_id
from {{ source('manual', 'albumbuddy_internal') }}
