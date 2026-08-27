/*
  stg_mystarroom__product_contents
  ─────────────────────────────────────────────
  레거시 대응 : pg_mystarroom_public.tb_commerce_product_content
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('mystarroom', 'tb_commerce_product_content') }}
