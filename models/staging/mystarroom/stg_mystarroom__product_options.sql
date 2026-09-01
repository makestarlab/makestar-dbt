/*
  stg_mystarroom__product_options
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_commerce_product_option
  grain       : 원천과 동일
*/

select
    id,
    name,
    product_id,
    hs_code,
    items_info,
    shipping_type,
    description,
    reward_idx,
    reward_code,
    hs_code_description,
    event_id,

    -- 메타는 맨 뒤
    datastream_metadata
from {{ source('mystarroom', 'tb_commerce_product_option') }}
