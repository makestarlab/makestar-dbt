/*
  stg_oms__skus
  ─────────────────────────────────────────────
  레거시 대응 : pg_oms_public.mst_sku
  grain       : 원천과 동일
  위험        : ⚠️ mst_sku 직발주 변형 SKU 중복
*/

select
    -- TODO: 컬럼 리네임 / 타입 캐스팅
    *
from {{ source('oms', 'mst_sku') }}
