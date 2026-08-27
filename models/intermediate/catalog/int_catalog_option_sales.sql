/*
  int_catalog_option_sales
  ─────────────────────────────────────────────
  레거시 대응 : datamart.vw_product_option_info
  grain       : 이벤트 × 옵션
  위험        : 🔴 2.69배 과다집계 발원지
*/

-- 🔴 레거시:
--      SELECT ..., sum(sales_qty) as sales_quantity
--      FROM vw_product_option_info WHERE content_sales_base='true' GROUP BY ALL
--    이 sum() 이 "N종 중 M매 랜덤 증정" 풀 전체를 더해 앨범수량을 2.69배로 만든다.
--    → 여기서는 풀 구조를 보존하고, 배분은 int_album_unit_allocation 이 담당.
select
    product_event_id,
    product_option_id,
    -- pool_size: 풀에 속한 종 수
    -- draw_count: 실제 증정 매수
    cast(null as int64) as pool_size,
    cast(null as int64) as draw_count
from {{ ref('int_catalog_items') }}
where false
