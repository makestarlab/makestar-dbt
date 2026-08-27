/*
  int_orders_classified
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 market_type/biz_type/channel_type CASE 트리
  grain       : 전 채널 주문 × 옵션 (행 수 불변)
  위험        : 🔴 최고 위험 - 분류 로직
*/

-- 🔴 레거시 CASE 트리 약 90줄. 오버라이드 조인과 분리해서 여기에만 둔다.
--    행 수는 절대 변하면 안 됨 → equal_rowcount 테스트 필수.
--
--    참고: seed_biz_type_rules.csv 로 데이터화하는 것도 검토할 만하다.
--          (product_type, product_category) → (market_type, biz_type, channel_type)
select
    t.*,
    case
        when t.product_type = 'B'    and t.product_category in ('상품','차액지불') then 'B2B'
        when t.product_type = '앨범버디' and t.product_category = '상품' then '앨범버디'
        -- TODO: 나머지 이식
        else 'B2C'
    end as market_type,
    cast(null as string) as biz_type,     -- TODO
    cast(null as string) as channel_type  -- TODO
from {{ ref('int_orders_unioned') }} t
