/*
  int_catalog_items
  ─────────────────────────────────────────────
  레거시 대응 : datamart.vw_commerce_items_v2
  grain       : 상품 × 옵션 × SKU
  위험        : 🔴 mapper 의존성 제거 대상
*/

-- 🔴 레거시 vw_commerce_items_v2 는 order_biz_mapper_objects 를 참조한다.
--    카탈로그가 매출 분류 매퍼에 의존하는 건 순환 구조. 여기서 끊을 것.
with products as (
    select * from {{ ref('stg_mystarroom__products') }}
),
options as (
    select * from {{ ref('stg_mystarroom__product_options') }}
),
skus as (
    select * from {{ ref('stg_mystarroom__product_event_data') }}
)
select
    -- TODO: vw_commerce_items_v2 정의 이식
    cast(null as string) as product_id
from products
where false
