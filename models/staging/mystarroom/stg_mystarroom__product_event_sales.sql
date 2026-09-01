/*
  stg_mystarroom__product_event_sales
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_commerce_product_event_sales_data
  grain       : 원천과 동일
*/

select
    id,
    sales_start_at,
    sales_end_at,
    shipping_process_start_at,
    legacy_exchange_rate,
    exchange_rate_correction_rate,
    product_purchase_limit,
    user_purchase_limit,
    group_purchase_info,
    is_refundable,
    shipping_charge,
    exchange_rate_id,
    product_event_id,
    option_list,
    bonus_list,
    country_code_list,
    sales_country_limits_type,
    free_shipping_info,
    limit_base_option_item_id,
    option_item_purchase_limit,
    sales_channel,
    has_option_purchase_limit,
    has_option_item_purchase_limit,
    has_user_purchase_limit,
    sales_channels,

    -- 메타는 맨 뒤
    datastream_metadata
from {{ source('mystarroom', 'tb_commerce_product_event_sales_data') }}
