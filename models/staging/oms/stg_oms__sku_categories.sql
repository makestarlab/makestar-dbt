/*
  stg_oms__sku_categories
  ─────────────────────────────────────────────
  레거시 대응 : pg_oms_public.mst_sku_category
  grain       : 원천과 동일
  
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('oms', 'mst_sku_category') }}
