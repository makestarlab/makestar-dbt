/*
  stg_mystarroom__additional_orders
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_commerce_additional_order
  grain       : 원천과 동일
*/

select
    id,
    order_number,
    order_status,
    ordered_data,
    payment_request_id,
    payment_data,
    manager_id,
    user_id,

    -- 메타는 맨 뒤
    created_at,
    updated_at,
    datastream_metadata
from {{ source('mystarroom', 'tb_commerce_additional_order') }}
