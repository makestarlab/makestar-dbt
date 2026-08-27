/*
  stg_manual__archived_orders
  ─────────────────────────────────────────────
  레거시 대응 : datamart.archived_orders
  grain       : 과거 주문 1건
  
*/

select *
from {{ source('manual', 'archived_orders') }}
