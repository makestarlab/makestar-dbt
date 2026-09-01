/*
  int_orders_offline
  -----------------------------------------------
  레거시 대응 : pre_total_orders 의 offline CTE (매장 9개 UNION 부분만)
  grain       : 매장 주문
  주의        : 미주유럽 매장은 stg_manual__offline_orders 가 country_code 를
                'US' 로 고정하지만 레거시는 left(store_name, 2) 로 동적 계산한다.
                여기서 store_name 으로 다시 계산해 바로잡는다.
                대만은 vw_commerce_exchange_rate 가 아니라 googlefinance 단일소스이고
                결측이면 41 을 하드코딩한다 (레거시 그대로).
  검증        : 대만 제외 8개 매장 34,218행 완전 일치 (레거시 대비). 대만은 이
                환경의 서비스 계정에 Drive API 권한이 없어 external.
                country_exchange_rate_googlefinance (Google Sheets 소스) 를
                직접 조회하지 못해 검증 불가 — 로직만 이식, 실행 시 BigQuery
                Drive 권한이 있는 계정에서 별도 확인 필요.
*/

with
    manual__offline_orders as (select * from {{ ref('stg_manual__offline_orders') }}),
    exchange_rates as (select * from {{ ref('int_exchange_rates_unioned') }}),

    japan_type_resolved as (
        select
            *,
            case
                when store_label = '일본 오프라인매장' and store_name = '타워레코드' then '타워레코드'
                when store_label = '일본 오프라인매장' and store_name = '누에라(FC)' then '누에라(FC)'
                when store_label = '일본 오프라인매장' and store_name = '누에라(공연)' then '누에라(공연)'
                when store_label = '일본 오프라인매장' and store_name = '누에라(음반)' then '누에라(음반)'
                else store_label
            end as product_type_resolved,
            case
                when store_label = '미주유럽 오프라인매장' then left(store_name, 2)
                else country_code
            end as order_country_code_resolved
        from manual__offline_orders
    ),

    exchange_by_currency as (
        select rate_date, currency, rate
        from exchange_rates
        where rate_source != 'googlefinance'
    ),
    exchange_taiwan as (
        select rate_date, rate
        from exchange_rates
        where rate_source = 'googlefinance'
    )

select
    concat(o.store_label, ' | 데이터 입력') as data_source,
    cast(null as string) as order_no,
    o.order_date,
    o.order_date as pay_date,
    o.product_type_resolved as product_type,
    o.product_type_resolved as product_category,
    cast(null as string) as parent_product_name,
    o.product_code as ms_product_code,
    o.product_name as ms_product_name,
    cast(null as string) as ms_option_code,
    cast(null as string) as ms_option_name,
    o.product_code,
    o.product_name,
    cast(null as string) as option_code,
    cast(null as string) as option_name,
    o.artist_name as ip_name,
    o.event_id,
    o.pay_amount * case
        when o.currency = 'KRW' then 1.0
        when o.order_country_code_resolved = 'TW' then coalesce(tw.rate, 41)
        else ex.rate
    end as product_revenue,
    0 as shipping_revenue,
    o.pay_amount * case
        when o.currency = 'KRW' then 1.0
        when o.order_country_code_resolved = 'TW' then coalesce(tw.rate, 41)
        else ex.rate
    end as total_revenue,
    o.order_qty,
    o.order_qty * o.album_qty as order_album_qty,
    cast(null as string) as logis_cd,
    o.order_country_code_resolved as order_country_code,
    cast(null as string) as shipping_country_code,
    cast(null as string) as user_id
from japan_type_resolved o
left join exchange_by_currency ex
    on o.order_date = ex.rate_date and upper(o.currency) = ex.currency
left join exchange_taiwan tw
    on o.order_date = tw.rate_date and o.order_country_code_resolved = 'TW'
where o.order_date is not null
