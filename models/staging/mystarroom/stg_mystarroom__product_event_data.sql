/*
  stg_mystarroom__product_event_data
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_commerce_product_event_data
  grain       : 원천과 동일
*/

select
    id,
    product_id,
    code,
    creator_type,
    description,
    event_info,
    event_status,
    funding_info,
    title,
    product_event_type,
    is_displayed,
    market_type,
    manager_id,
    winning_category_id,
    hs_code,
    purchase_limit_count,
    purchase_limit_type,
    b2b_discount_type,
    is_contain_poster,
    is_display_stock,
    is_refundable,
    winner_announcement_status,
    display_status,
    sale_status,
    is_sale_status_manual,

    -- 메타는 맨 뒤
    created_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_commerce_product_event_data') }}
