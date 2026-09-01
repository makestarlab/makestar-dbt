/*
  stg_albumbuddy__orders
  -----------------------------------------------
  레거시 대응 : public.order
  grain       : 원천과 동일
*/

select
    id,
    user_id,
    status,
    total_price,
    shipping_cost,
    shipping_address,
    shipping_message,
    currency,
    exchange_rate,
    admin_memo,
    makestar_id,
    payment_balance,
    agency_fee,
    event_application_id,
    goods_price,
    payment_price,
    mid,
    payment_method,
    all_stocked,
    delivery_agency,
    stocked_at,
    used_points,
    points_value,
    exchange_rate_snapshot,
    paid_currency,
    pricing_snapshot,

    -- 메타는 맨 뒤
    created_at,
    updated_at,
    datastream_metadata
from {{ source('albumbuddy', 'order') }}
