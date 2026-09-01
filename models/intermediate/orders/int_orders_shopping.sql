/*
  int_orders_shopping
  -----------------------------------------------
  레거시 대응 : pre_commerce_orders 2번 UNION (쇼핑)
  grain       : 주문 × 옵션
  주의        : order_album_qty 는 int_orders_reward 와 같은 이유로 null.
*/

with
    orders_enriched as (select * from {{ ref('int_orders_enriched') }}),
    order_items_enriched as (select * from {{ ref('int_order_items_enriched') }}),
    catalog_items as (select * from {{ ref('int_catalog_items') }}),
    catalog_event_resolution as (select * from {{ ref('int_catalog_event_resolution') }}),

    catalog_artists as (
        select distinct artist_name, product_id, product_name
        from catalog_items
    ),

    matched as (
        select
            'new_commerce_db' as data_source,
            o.order_id as order_no,
            o.payment_status,
            o.order_created_at_kst as order_date,
            o.payment_at_kst as pay_date,
            case o.order_type when 'B2B' then 'B' when 'B2C' then 'N' end as product_type,
            '상품' as product_category,
            ii.product_name as parent_product_name,
            oi.product_event_code as ms_product_code,
            oi.product_event_name as ms_product_name,
            oi.product_option_id as ms_option_code,
            oi.product_option_name as ms_option_name,
            oi.product_event_code as product_code,
            oi.product_event_name as product_name,
            oi.product_option_id as option_code,
            oi.product_option_name as option_name,
            coalesce(ii.artist_name, cast(null as string)) as ip_name,
            ec.event_id,
            (oi.product_option_pay_amount * o.exchange_rate) as product_revenue,
            sum(oi.product_option_pay_amount * o.exchange_rate) over (partition by o.order_id) as total_product_revenue,
            safe_divide(
                (oi.product_option_pay_amount * o.exchange_rate),
                sum(oi.product_option_pay_amount * o.exchange_rate) over (partition by o.order_id)
            ) as product_revenue_portion,
            o.logis_pay_amount * o.exchange_rate as shipping_revenue,
            oi.product_option_pay_quantity as order_qty,
            cast(null as int64) as order_album_qty,
            o.logis_code as logis_cd,
            o.order_country_code,
            o.delivery_country_code as shipping_country_code,
            o.user_id
        from orders_enriched o
        join order_items_enriched oi on o.order_id = oi.order_id and o.order_number = oi.order_number
        left join catalog_artists ii on oi.product_id = ii.product_id
        left join catalog_event_resolution ec
            on oi.product_event_id = ec.product_event_id
            and oi.product_option_id = ec.product_option_id
        where (o.payment_status in ('CONFIRMED', 'PARTIAL_CANCELED') or o.order_status = 'PAYMENT_PROCESSING')
          and o.order_status in ('PAYMENT_PROCESSING', 'PAYMENT_COMPLETED', 'INVENTORY_CHECKING', 'SHIPPING_PROCESSING', 'COMPLETED')
          and oi.product_event_type in ('쇼핑')
    )

select
    data_source, order_no, payment_status, order_date, pay_date, product_type, product_category, parent_product_name,
    ms_product_code, ms_product_name, ms_option_code, ms_option_name,
    product_code, product_name, option_code, option_name, ip_name,
    string_agg(event_id, ', ' order by event_id) as event_id,
    product_revenue, total_product_revenue, product_revenue_portion, shipping_revenue,
    order_qty, order_album_qty, logis_cd, order_country_code, shipping_country_code, user_id
from matched
group by
    data_source, order_no, payment_status, order_date, pay_date, product_type, product_category, parent_product_name,
    ms_product_code, ms_product_name, ms_option_code, ms_option_name,
    product_code, product_name, option_code, option_name, ip_name,
    product_revenue, total_product_revenue, product_revenue_portion, shipping_revenue,
    order_qty, order_album_qty, logis_cd, order_country_code, shipping_country_code, user_id
