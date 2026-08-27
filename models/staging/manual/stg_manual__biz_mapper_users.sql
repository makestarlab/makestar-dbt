/*
  stg_manual__biz_mapper_users
  ─────────────────────────────────────────────
  레거시 대응 : datamart.order_biz_mapper_users
  grain       : 유저 × 분류 1건
  
*/

select *
from {{ source('manual', 'order_biz_mapper_users') }}
