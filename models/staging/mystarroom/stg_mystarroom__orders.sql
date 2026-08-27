/*
  stg_mystarroom__orders
  -----------------------------------------------
  레거시 대응 : datamart.tb_commerce_orders_flattened -> vw_commerce_orders
  grain       : 주문 (order_id x order_number)
  주의        : 소스가 주문 x 옵션 grain 이므로 여기서 주문 단위로 압축한다.
                exchange_rate 와 order_country_code 는 소스에 없다.
                int_orders_enriched 에서 조인으로 붙인다.
*/

select
    order_id,
    order_number,
    order_status,
    order_type,
    payment_id,
    payment_status,
    payment_method,
    payment_method_extra,
    pg_code,
    logis_code,
    logis_pay_amount,
    duties_and_taxes,
    duty_handling_fee,
    currency,
    cast(user_id as string) as user_id,
    ip_address_info_id,
    delivery_country_code,
    {{ to_kst('order_created_at') }} as order_created_at_kst,
    {{ to_kst('payment_at') }}       as payment_at_kst,
    updated_at
from {{ source('dw_legacy', 'tb_commerce_orders_flattened') }}
qualify row_number() over (
    partition by order_id, order_number order by updated_at desc
) = 1
