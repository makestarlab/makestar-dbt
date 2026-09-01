/*
  int_orders_albumbuddy
  -----------------------------------------------
  레거시 대응 : pre_total_orders 의 albumbuddy 블록
  grain       : 앨범버디 주문
  검증        : order/package_delivery 블록 14,057행 완전 일치 (레거시 대비).
                pob_outbound 블록은 이 환경에 Drive API 권한이 없어 검증 불가
                (int_orders_offline 의 대만 케이스와 동일한 제약).
*/

with
    orders as (select * from {{ ref('stg_albumbuddy__orders') }}),
    package_deliveries as (select * from {{ ref('stg_albumbuddy__package_deliveries') }}),
    pob_outbound as (select * from {{ ref('stg_albumbuddy__pob_outbound') }}),
    exchange_rates as (select * from {{ ref('int_exchange_rates_unioned') }}),
    albumbuddy_internal as (select * from {{ ref('stg_manual__albumbuddy_internal') }}),

    combined as (
        select id, user_id, created_at, currency, payment_balance
        from orders
        where user_id not in (select user_id from albumbuddy_internal)
          and status in ('payment_complete', 'payment_partial_canceled')
          and (delivery_agency = false or delivery_agency is null)

        union all

        select id, user_id, created_at, currency, payment_balance
        from package_deliveries
        where user_id not in (select user_id from albumbuddy_internal)
          and status in ('payment_complete', 'payment_partial_canceled')

        union all

        select
            cast(null as string) as id,
            cast(null as string) as user_id,
            cast(outbound_date as timestamp) as created_at,
            currency,
            total as payment_balance
        from pob_outbound
        where type = 'out-bound'
    ),

    exchange_matched as (
        select rate_date, currency, rate
        from exchange_rates
        where rate_source != 'googlefinance'
    )

select
    'albumbuddy.public.order' as data_source,
    a.id as order_no,
    {{ to_kst('a.created_at') }} as order_date,
    {{ to_kst('a.created_at') }} as pay_date,
    '앨범버디' as product_type,
    '상품' as product_category,
    cast(null as string) as parent_product_name,
    cast(null as string) as ms_product_code,
    cast(null as string) as ms_product_name,
    cast(null as string) as ms_option_code,
    cast(null as string) as ms_option_name,
    cast(null as string) as product_code,
    cast(null as string) as product_name,
    cast(null as string) as option_code,
    cast(null as string) as option_name,
    cast(null as string) as ip_name,
    cast(null as string) as event_id,
    0.0 as product_revenue,
    0.0 as shipping_revenue,
    a.payment_balance * ex.rate as total_revenue,
    0 as order_qty,
    0 as order_album_qty,
    cast(null as string) as logis_cd,
    cast(null as string) as order_country_code,
    cast(null as string) as shipping_country_code,
    a.user_id
from combined a
left join exchange_matched ex
    on date(timestamp_add(a.created_at, interval 9 hour)) = ex.rate_date
    and upper(a.currency) = ex.currency
