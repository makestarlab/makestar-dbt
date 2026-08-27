/*
  int_catalog_event_resolution
  ─────────────────────────────────────────────
  레거시 대응 : pre_commerce_orders 쇼핑 브랜치의 sku_name_component_1 매칭
  grain       : 이벤트 × 옵션
  위험        : ⚠️ SKU명 파싱 휴리스틱
*/

-- ⚠️ 레거시는 sku_name_component_1 이 production.project.id 또는
--    tb_commerce_product_event_data.code 에 있으면 event_id 로 간주한다.
--    문자열 기반 휴리스틱이므로 조용히 틀릴 수 있다 → 커버리지 테스트 필수.
with known_events as (
    select cast(id as string) as event_id from {{ ref('stg_production__projects') }}
    union all
    select code as event_id from {{ ref('stg_mystarroom__product_event_data') }}
    where product_event_type = 1
)
select distinct
    i.product_event_id,
    i.product_option_id,
    i.sku_name_component_1 as event_id
from {{ ref('int_catalog_items') }} i
join known_events e on i.sku_name_component_1 = e.event_id
