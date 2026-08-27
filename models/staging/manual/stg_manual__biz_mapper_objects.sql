/*
  stg_manual__biz_mapper_objects
  -----------------------------------------------
  레거시 대응 : datamart.order_biz_mapper_objects
  grain       : 매퍼 규칙 1건
  위험        : 레거시는 OR 3개 조건으로 조인해 행을 복제할 수 있다.
                objects 는 덮어쓸 값을 직접 들고 있고,
                asis 와 tobe 쌍은 order_biz_mapper_users 에만 있다.
*/

select
    product_type,
    product_category,
    event_id,
    product_code,
    order_no,
    market_type,
    biz_type,
    channel_type,
    case
        when order_no     is not null and order_no     != '' then 'order_no'
        when product_code is not null and product_code != '' then 'product_code'
        when event_id     is not null and event_id     != '' then 'event_id'
    end as match_key
from {{ source('manual', 'order_biz_mapper_objects') }}
