/*
  stg_mystarroom__products
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_commerce_product
  grain       : 원천과 동일
*/

select
    id,
    product_code,
    title,
    hash_tag,
    is_displayed,
    is_active,
    artist_id,
    company_id,
    manager_id,
    released_at,

    -- 메타는 맨 뒤
    created_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_commerce_product') }}
