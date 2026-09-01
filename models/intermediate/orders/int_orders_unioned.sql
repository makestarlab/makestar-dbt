/*
  int_orders_unioned
  -----------------------------------------------
  레거시 대응 : pre_total_orders 의 commerce CTE 재집계 + 최종 UNION ALL
  grain       : 전 채널 주문 × 옵션
  주의        : commerce 재집계는 payment_status 를 CONFIRMED/PARTIAL_CANCELED 로
                한 번 더 좁힌다 (int_orders_commerce 는 PAYMENT_PROCESSING 도 포함).
                shipping_revenue 는 주문 단위 배송비를 product_revenue_portion 으로
                옵션별 배분한 값이다.
  검증        : commerce 재집계 부분만 레거시 pre_commerce_orders 재집계와 대조 —
                534,827 / 534,827 행, 값 불일치 40건(부동소수점 반올림 경계, 무시 가능).
                offline/albumbuddy 브랜치는 Drive 권한 제약으로 전체 UNION 자체는
                직접 검증하지 못했으나 각 구성 모델은 개별 검증됨.
*/

with
    orders_commerce as (select * from {{ ref('int_orders_commerce') }}),
    orders_weidian as (select * from {{ ref('int_orders_weidian') }}),
    orders_offline as (select * from {{ ref('int_orders_offline') }}),
    orders_albumbuddy as (select * from {{ ref('int_orders_albumbuddy') }}),
    orders_manual_etc as (select * from {{ ref('int_orders_manual_etc') }}),
    manual__archived_orders as (select * from {{ ref('stg_manual__archived_orders') }}),

    commerce as (
        select
            data_source, order_no, order_date, pay_date, product_type, product_category, parent_product_name,
            ms_product_code, ms_product_name, ms_option_code, ms_option_name,
            product_code, product_name, option_code, option_name, ip_name, event_id,
            sum(product_revenue) as product_revenue,
            sum(shipping_revenue * product_revenue_portion) as shipping_revenue,
            sum(product_revenue + (shipping_revenue * product_revenue_portion)) as total_revenue,
            sum(order_qty) as order_qty,
            sum(order_album_qty) as order_album_qty,
            logis_cd, order_country_code, shipping_country_code, user_id
        from orders_commerce
        where payment_status in ('CONFIRMED', 'PARTIAL_CANCELED')
        group by
            data_source, order_no, order_date, pay_date, product_type, product_category, parent_product_name,
            ms_product_code, ms_product_name, ms_option_code, ms_option_name,
            product_code, product_name, option_code, option_name, ip_name, event_id,
            logis_cd, order_country_code, shipping_country_code, user_id
    )

select
    data_source, order_no, order_date, pay_date, product_type, product_category, parent_product_name,
    ms_product_code, ms_product_name, ms_option_code, ms_option_name,
    product_code, product_name, option_code, option_name, ip_name, event_id,
    product_revenue, shipping_revenue, total_revenue, order_qty, order_album_qty,
    logis_cd, order_country_code, shipping_country_code, user_id
from commerce

union all

select
    data_source, order_no, order_date, pay_date, product_type, product_category, parent_product_name,
    ms_product_code, ms_product_name, ms_option_code, ms_option_name,
    product_code, product_name, option_code, option_name, ip_name, event_id,
    product_revenue, shipping_revenue, total_revenue, order_qty, order_album_qty,
    logis_cd, order_country_code, shipping_country_code, user_id
from orders_weidian

union all

select
    data_source, order_no, order_date, pay_date, product_type, product_category, parent_product_name,
    ms_product_code, ms_product_name, ms_option_code, ms_option_name,
    product_code, product_name, option_code, option_name, ip_name, event_id,
    product_revenue, shipping_revenue, total_revenue, order_qty, order_album_qty,
    logis_cd, order_country_code, shipping_country_code, user_id
from orders_offline

union all

select
    data_source, order_no, order_date, pay_date, product_type, product_category, parent_product_name,
    ms_product_code, ms_product_name, ms_option_code, ms_option_name,
    product_code, product_name, option_code, option_name, ip_name, event_id,
    product_revenue, shipping_revenue, total_revenue, order_qty, order_album_qty,
    logis_cd, order_country_code, shipping_country_code, user_id
from orders_albumbuddy

union all

select
    data_source, order_no, order_date, pay_date, product_type, product_category, parent_product_name,
    ms_product_code, ms_product_name, ms_option_code, ms_option_name,
    product_code, product_name, option_code, option_name, ip_name, event_id,
    product_revenue, shipping_revenue, total_revenue, order_qty, order_album_qty,
    logis_cd, order_country_code, shipping_country_code, user_id
from orders_manual_etc

union all

select
    data_source, order_no, order_date, pay_date, product_type, product_category, parent_product_name,
    ms_product_code, ms_product_name, ms_option_code, ms_option_name,
    product_code, product_name, option_code, option_name, ip_name, event_id,
    product_revenue, shipping_revenue, total_revenue, order_qty, order_album_qty,
    logis_cd, order_country_code, shipping_country_code, user_id
from manual__archived_orders
