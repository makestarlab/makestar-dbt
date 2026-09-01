/*
  int_order_items_enriched
  -----------------------------------------------
  레거시 대응 : datamart.vw_commerce_order_items
  grain       : 주문 × 아이템
*/

with
    order_items as (select * from {{ ref('stg_mystarroom__order_items') }}),
    product_options as (select * from {{ ref('stg_mystarroom__product_options') }}),
    product_event_data as (select * from {{ ref('stg_mystarroom__product_event_data') }}),
    additional_orders as (select * from {{ ref('stg_mystarroom__additional_orders') }})

select
    oi.order_id,
    oi.order_number,
    oi.product_event_id,
    oi.product_event_code,
    oi.product_event_type,
    json_value(pe.title, '$.ko') as product_event_name,
    oi.product_id,
    oi.product_code,
    oi.company_id,
    oi.product_option_id,
    json_value(po.name, '$.ko') as product_option_name,
    oi.product_option_pay_quantity,
    oi.product_option_pay_amount
from order_items oi
join product_event_data pe on oi.product_event_id = cast(pe.id as string)
join product_options po on oi.product_option_id = cast(po.id as string)

union all

select
    order_number as order_id,
    cast(null as string) as order_number,
    cast(null as string) as product_event_id,
    cast(null as string) as product_event_code,
    '차액지불' as product_event_type,
    json_value(ordered_data, '$.order_item_name') as product_event_name,
    cast(null as string) as product_id,
    cast(null as string) as product_code,
    cast(null as string) as company_id,
    cast(null as string) as product_option_id,
    json_value(ordered_data, '$.order_item_name') as product_option_name,
    0 as product_option_pay_quantity,
    safe_cast(json_value(payment_data, '$.response.balanceAmount') as float64) as product_option_pay_amount
from additional_orders
