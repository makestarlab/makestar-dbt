/*
  stg_mystarroom__product_contents
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_commerce_product_content
  grain       : 원천과 동일
*/

select
    id,
    content_type,
    description,
    artist_id,
    members_id,
    is_displayed,
    title,
    index,
    item_code,
    product_id,
    reward_item_idx,
    reward_item_option_idx,
    is_special,
    version_name,
    sku_category,
    sku_code,
    weight_index,

    -- 메타는 맨 뒤
    datastream_metadata
from {{ source('mystarroom', 'tb_commerce_product_content') }}
