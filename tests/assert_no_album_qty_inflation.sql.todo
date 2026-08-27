-- 앨범수량 과다집계 회귀 방지.
-- 배분 결과 합이 주문수량 합을 넘어서는 주문이 있으면 실패.
select
    a.order_no,
    sum(a.allocated_units) as allocated,
    max(o.order_qty)       as ordered
from {{ ref('int_album_unit_allocation') }} a
join {{ ref('fct_orders') }} o using (order_no)
group by 1
having sum(a.allocated_units) > max(o.order_qty) * 20   -- 상한선. 실제 값으로 조정할 것
