/*
  int_orders_manual_etc
  -----------------------------------------------
  레거시 대응 : pre_total_orders 의 etc CTE + offline CTE 의 팬클럽 자체 링크 블록
  grain       : 수기 주문
  주의        : 레거시는 팬클럽 자체 링크를 offline CTE 안에 뒀지만
                (물리 매장이 아니라 리워드성 수기입력이라) 여기 manual_etc 로 옮겼다.
                stg_manual__extra_orders 가 4종을 이미 한 모델로 묶어뒀다.
  검증        : 매출 합계는 완전 일치. 행 수는 452 / 471 로 차이 19건 —
                레거시는 event_extra_orders(팬클럽 자체 링크) 에만
                order_date is not null 필터가 없는데, stg_manual__extra_orders 는
                4종 전부에 동일 필터를 건다. 차이나는 19행은 order_date NULL +
                pay_amount 0 인 행으로 매출에는 영향 없음. staging 수정은 별도로.
*/

with
    manual__extra_orders as (select * from {{ ref('stg_manual__extra_orders') }})

select
    data_source,
    cast(null as string) as order_no,
    order_date,
    order_date as pay_date,
    product_type,
    product_category,
    cast(null as string) as parent_product_name,
    product_code as ms_product_code,
    product_name as ms_product_name,
    cast(null as string) as ms_option_code,
    cast(null as string) as ms_option_name,
    product_code,
    product_name,
    cast(null as string) as option_code,
    cast(null as string) as option_name,
    artist_name as ip_name,
    event_id,
    pay_amount as product_revenue,
    0.0 as shipping_revenue,
    pay_amount as total_revenue,
    order_qty,
    order_qty * album_qty as order_album_qty,
    case when product_type = '리워드' then 'LGS001' else '' end as logis_cd,
    case when product_type = '리워드' then 'KR' else '' end as order_country_code,
    case when product_type = '리워드' then 'KR' else '' end as shipping_country_code,
    cast(null as string) as user_id
from manual__extra_orders
