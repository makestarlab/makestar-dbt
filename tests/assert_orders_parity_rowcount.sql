-- Phase 2 전환 검증: 신규 fct_orders 와 레거시 total_orders 의 행 수 일치
-- 반환 행이 있으면 실패
with new_ as (select count(*) c from {{ ref('fct_orders') }}),
     old_ as (select count(*) c from {{ source('dw_legacy', 'total_orders') }})
select new_.c as new_rows, old_.c as old_rows
from new_, old_
where new_.c != old_.c
