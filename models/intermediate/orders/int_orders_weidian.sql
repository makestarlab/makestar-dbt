/*
  int_orders_weidian
  -----------------------------------------------
  레거시 대응 : pre_total_orders 의 external CTE (+ vw_weidian_orders)
  grain       : 웨이디엔 주문 × 옵션
  주의        : order_album_qty 는 int_orders_reward 와 같은 이유로 null.
                ms_option_code/ms_option_name/parent_product_name 은 레거시가
                vw_product_option_info 에서 가져오지만, 여기서는 sum(sales_qty) 없이
                순수 표시용 속성만 필요하므로 int_catalog_items 에서 직접 뽑는다.
*/

with
    weidian_orders as (select * from {{ ref('stg_weidian__orders') }}),
    weidian_order_items as (select * from {{ ref('stg_weidian__order_items') }}),
    weidian_items as (select * from {{ ref('stg_weidian__items') }}),
    exchange_rates as (select * from {{ ref('int_exchange_rates_unioned') }}),
    catalog_items as (select * from {{ ref('int_catalog_items') }}),

    -- 레거시 vw_weidian_orders
    weidian_enriched as (
        select
            o.order_id,
            o.status as order_status,
            o.refund_status,
            o.time as order_time,
            o.buyer_name,
            oi.total_price as product_revenue,
            o.express_fee * safe_divide(oi.total_price, sum(oi.total_price) over (partition by o.order_id)) as shipping_revenue,
            oi.product_id,
            i.product_name,
            i.product_merchant_code,
            i.option_id,
            i.option_name,
            i.option_merchant_code,
            oi.price as product_price,
            oi.quantity,
            oi.refund_product_price as product_refund,
            oi.refund_express_price as shipping_refund
        from weidian_orders o
        join weidian_order_items oi on o.order_id = oi.order_id
        left join weidian_items i on oi.product_id = i.product_id and oi.option_id = i.option_id
    ),

    catalog_options as (
        select
            product_option_id,
            any_value(product_event_code) as product_event_code,
            any_value(product_event_name) as product_event_name,
            any_value(product_option_name) as product_option_name,
            any_value(product_name) as product_name
        from catalog_items
        where product_option_id is not null
        group by product_option_id
    ),

    catalog_event_lookup as (
        select distinct artist_name, product_option_id, event_id
        from catalog_items
        where event_id is not null
    ),

    exchange_cny as (
        select rate_date, rate as exchange_rate
        from exchange_rates
        where currency = 'CNY' and rate_source != 'googlefinance'
    )

select
    '웨이디엔' as data_source,
    w.order_id as order_no,
    date(datetime_add(w.order_time, interval 9 hour)) as order_date,
    date(datetime_add(w.order_time, interval 9 hour)) as pay_date,
    '웨이디엔' as product_type,
    '웨이디엔' as product_category,
    co.product_name as parent_product_name,
    co.product_event_code as ms_product_code,
    co.product_event_name as ms_product_name,
    co.product_option_id as ms_option_code,
    co.product_option_name as ms_option_name,
    w.product_id as product_code,
    w.product_name as product_name,
    w.option_id as option_code,
    w.option_name as option_name,
    ce.artist_name as ip_name,
    ce.event_id,
    (w.product_revenue - (case when w.refund_status in ('1', '3') then 0 else w.product_refund end)) * ex.exchange_rate as product_revenue,
    (w.shipping_revenue - (case when w.refund_status in ('1', '3') then 0 else w.shipping_refund end)) * ex.exchange_rate as shipping_revenue,
    (
        (w.product_revenue + w.shipping_revenue)
        - (
            (case when w.refund_status in ('1', '3') then 0 else w.product_refund end)
            + (case when w.refund_status in ('1', '3') then 0 else w.shipping_refund end)
        )
    ) * ex.exchange_rate as total_revenue,
    ceiling(w.quantity - (case when w.refund_status in ('1', '3') then 0 else safe_divide(w.product_refund, w.product_price) end)) as order_qty,
    cast(null as int64) as order_album_qty,
    cast(null as string) as logis_cd,
    'CN' as order_country_code,
    'CN' as shipping_country_code,
    w.buyer_name as user_id
from weidian_enriched w
join exchange_cny ex on date(datetime_add(w.order_time, interval 9 hour)) = ex.rate_date
left join catalog_options co on w.option_merchant_code = co.product_option_id
left join catalog_event_lookup ce on w.option_merchant_code = ce.product_option_id
where w.order_status in ('50', '30', '20')
