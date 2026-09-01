/*
  int_orders_overridden
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 order_biz_mapper 조인 2단
  grain       : 전 채널 주문 × 옵션 (행 수 불변이어야 함)
  위험        : 🔴 OR 조인 - 행 복제 위험
*/

-- 🔴🔴 이 프로젝트에서 가장 위험한 모델.
--
--  레거시 조인 조건:
--     ON  t.product_type = b.product_type
--     AND t.product_category = b.product_category
--     AND ( t.event_id = b.event_id
--        OR t.product_code = b.product_code
--        OR t.order_no = b.order_no )     ← OR 3개
--
--  한 주문이 두 규칙에 동시에 매칭되면 행이 복제되고 매출이 조용히 늘어난다.
--  → match_key 로 우선순위를 명시해 1:1 을 강제한다.

with ranked_map as (
    select
        *,
        row_number() over (
            partition by product_type, product_category,
                         coalesce(order_no, product_code, event_id)
            order by case match_key
                when 'order_no' then 1 when 'product_code' then 2 else 3 end
        ) as rn
    from {{ ref('stg_manual__biz_mapper_objects') }}
),
obj_map as (select * from ranked_map where rn = 1),

by_object as (
    select
        t.*,
        coalesce(m.market_type,  t.market_type)  as market_type_ovr,
        coalesce(m.biz_type,     t.biz_type)     as biz_type_ovr,
        coalesce(m.channel_type, t.channel_type) as channel_type_ovr
    from {{ ref('int_orders_classified') }} t
    left join obj_map m
           on t.product_type     = m.product_type
          and t.product_category = m.product_category
          and coalesce(t.order_no, t.product_code, t.event_id)
            = coalesce(m.order_no, m.product_code, m.event_id)
)
select
    b.*,
    coalesce(u.market_type_tobe, b.market_type_ovr) as market_type_final,
    coalesce(u.biz_type_tobe,    b.biz_type_ovr)    as biz_type_final
from by_object b
left join {{ ref('stg_manual__biz_mapper_users') }} u
       on b.market_type_ovr = u.market_type_asis
      and b.biz_type_ovr    = u.biz_type_asis
      and b.user_id         = u.user_id
