/*
  stg_albumbuddy__package_deliveries
  -----------------------------------------------
  레거시 대응 : public.package_delivery
  grain       : 원천과 동일
*/

select
    id,
    user_id,
    international_tracking_number,
    status,
    address_id,
    total_price,
    currency,
    payment_price,
    payment_balance,
    makestar_id,
    delivery_company,
    exchange_rate,
    payment_method,
    used_points,
    points_value,

    -- 메타는 맨 뒤
    created_at,
    updated_at,
    datastream_metadata
from {{ source('albumbuddy', 'package_delivery') }}
