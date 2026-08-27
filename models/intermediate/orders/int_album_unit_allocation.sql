/*
  int_album_unit_allocation
  ─────────────────────────────────────────────
  레거시 대응 : order_album_qty = order_qty * sum(sales_qty) 대체
  grain       : 주문 × 옵션 × parent_sku
  위험        : 🔴 2.69배 문제 해결 지점
*/

-- 🔴 레거시는 order_qty * sum(sales_qty) 로 앨범수량을 계산해 2.69배 과다집계된다.
--    "N종 중 M매 랜덤 증정" 풀에서는 실제 배분을 알 수 없으므로 2단계 모델로 추정한다.
--
--    1단계: oms_order_line_item_sku_preview 로 실배분이 확인되는 주문 → 실측
--    2단계: 미확인 주문 → 1단계 실측 분포를 사전확률로 하는 베이지안 블렌딩
--
--    ⚠️ 이 모델이 확정되기 전에는 시맨틱 레이어에 album_units 지표를 올리지 말 것.
select
    cast(null as string)  as order_no,
    cast(null as string)  as product_option_id,
    cast(null as string)  as parent_sku,
    cast(null as numeric) as allocated_units,
    cast(null as string)  as allocation_method  -- 'observed' | 'estimated'
from {{ ref('int_orders_commerce') }}
where false
