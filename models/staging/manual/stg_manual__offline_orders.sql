/*
  stg_manual__offline_orders
  ─────────────────────────────────────────────
  레거시 대응 : pre_total_orders 의 offline CTE (9개 매장 UNION)
  grain       : 매장 × 주문일 × 상품
  
*/

-- 레거시에서 매장마다 복붙된 9개 블록을 여기서 한 번에 정규화한다.
-- 원본 SQL 약 400줄이 이 모델로 흡수됨.
{% set stores = [
    ('offline_orders_makestarshop_',        '메이크스타샵',        'KR', none),
    ('offline_orders_space_china_',         '스페이스상하이',      'CN', 'currency'),
    ('offline_orders_space_guangzhou_',     '스페이스광저우',      'CN', 'currency'),
    ('offline_orders_space_shenzhen_',      '스페이스선전',        'CN', 'currency'),
    ('offline_orders_space_tokyo_',         '스페이스도쿄',        'JP', 'currency'),
    ('offline_orders_japan_',               '일본 오프라인매장',   'JP', 'currency'),
    ('offline_orders_china_',               '중국 오프라인매장',   'CN', 'currency'),
    ('offline_orders_taiwan_',              '대만 오프라인매장',   'TW', 'currency'),
    ('offline_orders_northamerica_europe_', '미주유럽 오프라인매장','US', 'currency')
] %}

{% for tbl, label, country, cur in stores %}
select
    '{{ label }}'   as store_label,
    '{{ country }}' as country_code,
    {% if cur %}currency{% else %}'KRW' as currency{% endif %},
    order_date,
    product_code,
    product_name,
    artist_name,
    event_id,
    pay_amount,
    order_qty,
    album_qty,
    -- 일본 매장은 store_name 으로 타워레코드/누에라 재분류 필요
    {% if tbl == 'offline_orders_japan_' or tbl == 'offline_orders_northamerica_europe_' %}
    store_name
    {% else %}
    cast(null as string) as store_name
    {% endif %}
from {{ source('manual', tbl) }}
where order_date is not null
{% if not loop.last %}union all{% endif %}
{% endfor %}
