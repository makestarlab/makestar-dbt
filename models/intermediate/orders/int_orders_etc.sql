/*
  int_orders_etc
  -----------------------------------------------
  레거시 대응 : pre_commerce_orders 3번 UNION (차액지불)
  grain       : 주문 × 옵션
*/

with
    orders_enriched as (select * from {{ ref('int_orders_enriched') }}),
    order_items_enriched as (select * from {{ ref('int_order_items_enriched') }}),
    users as (select * from {{ ref('stg_mystarroom__users') }})

select
    'new_commerce_db' as data_source,
    o.order_id as order_no,
    o.payment_status,
    o.order_created_at_kst as order_date,
    o.payment_at_kst as pay_date,
    case when u.has_group = true then 'B' else '차액지불' end as product_type,
    '차액지불' as product_category,
    '' as parent_product_name,
    oi.product_event_code as ms_product_code,
    oi.product_event_name as ms_product_name,
    oi.product_option_id as ms_option_code,
    oi.product_option_name as ms_option_name,
    oi.product_event_code as product_code,
    oi.product_event_name as product_name,
    oi.product_option_id as option_code,
    oi.product_option_name as option_name,
    cast(null as string) as ip_name,
    cast(null as string) as event_id,
    (oi.product_option_pay_amount * o.exchange_rate) as product_revenue,
    sum(oi.product_option_pay_amount * o.exchange_rate) over (partition by o.order_id) as total_product_revenue,
    safe_divide(
        (oi.product_option_pay_amount * o.exchange_rate),
        sum(oi.product_option_pay_amount * o.exchange_rate) over (partition by o.order_id)
    ) as product_revenue_portion,
    coalesce(o.logis_pay_amount * o.exchange_rate, 0) as shipping_revenue,
    oi.product_option_pay_quantity as order_qty,
    oi.product_option_pay_quantity as order_album_qty,
    o.logis_code as logis_cd,
    o.order_country_code,
    o.delivery_country_code as shipping_country_code,
    o.user_id
from orders_enriched o
join order_items_enriched oi on o.order_id = oi.order_id
join users u on o.user_id = cast(u.id as string)
where o.order_status not in ('CANCELED')
  and o.order_type = 'ETC'
