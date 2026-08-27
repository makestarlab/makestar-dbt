/*
  stg_manual__extra_orders
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 etc CTE + event_extra_orders_ 블록
  grain       : 채널 × 주문일 × 상품
*/

-- 수기 입력 4종. 레거시에서 각각 복붙돼 있던 걸 여기서 한 번에 정규화한다.
-- 컬럼 스키마가 네 테이블 모두 동일하다는 전제 (아래 검증 쿼리로 확인할 것).

{% set tables = [
    ('event_extra_orders', '팬클럽 자체 링크 | 데이터 입력', '리워드',         '리워드'),
    ('pocaalbum_orders',   '포카앨범 제작 | 데이터 입력',    '포카앨범 제작',  '포카앨범 제작'),
    ('album_extra_orders', '앨범 유통/도매 | 데이터 입력',   '앨범 유통/도매', '앨범 유통/도매'),
    ('extra_orders',       'B2C 기타 매출 | 데이터 입력',    'B2C 기타',       'B2C 기타')
] %}

{% for tbl, data_source, product_type, product_category in tables %}
select
    '{{ data_source }}'      as data_source,
    '{{ product_type }}'     as product_type,
    '{{ product_category }}' as product_category,
    order_date,
    product_code,
    product_name,
    artist_name,
    event_id,
    pay_amount,
    order_qty,
    album_qty
from {{ source('manual', tbl) }}
where order_date is not null
{% if not loop.last %}union all{% endif %}
{% endfor %}
