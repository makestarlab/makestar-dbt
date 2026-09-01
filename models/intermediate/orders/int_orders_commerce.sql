/*
  int_orders_commerce
  -----------------------------------------------
  레거시 대응 : datamart.pre_commerce_orders
  grain       : 주문 × 옵션
*/

select * from {{ ref('int_orders_reward') }}
union all
select * from {{ ref('int_orders_shopping') }}
union all
select * from {{ ref('int_orders_etc') }}
