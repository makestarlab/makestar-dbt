/*
  int_orders_reward
  -----------------------------------------------
  레거시 대응 : pre_commerce_orders 1번 UNION (이벤트/펀딩)
  grain       : 주문 × 옵션
  주의        : order_album_qty 는 int_catalog_option_sales / int_album_unit_allocation 이
                아직 (의도적으로) 미완성이라 null 로 둔다. 레거시는 이 자리에서
                sum(sales_qty) 를 곱해 앨범수량을 2.69배 과다집계했다 (README 참고).
                해당 모델이 채워지면 여기서 조인만 바꾸면 된다.
*/

with
    orders_enriched as (select * from {{ ref('int_orders_enriched') }}),
    order_items_enriched as (select * from {{ ref('int_order_items_enriched') }}),
    catalog_items as (select * from {{ ref('int_catalog_items') }}),

    catalog_artists as (
        select distinct artist_name, product_id, product_name
        from catalog_items
    )

select
    'new_commerce_db' as data_source,
    o.order_id as order_no,
    o.payment_status,
    o.order_created_at_kst as order_date,
    o.payment_at_kst as pay_date,
    '리워드' as product_type,
    '리워드' as product_category,
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
    oi.product_event_code as event_id,
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
where (o.payment_status in ('CONFIRMED', 'PARTIAL_CANCELED') or o.order_status = 'PAYMENT_PROCESSING')
  and o.order_status in ('PAYMENT_PROCESSING', 'PAYMENT_COMPLETED', 'INVENTORY_CHECKING', 'SHIPPING_PROCESSING', 'COMPLETED')
  and oi.product_event_type in ('이벤트', '펀딩')
