/*
  stg_production__exchange_history
  -----------------------------------------------
  레거시 대응 : production.country_exchange_history
  grain       : 원천과 동일
*/

select
    idx,
    code,
    locale,
    currency,
    price,
    write_date
from {{ source('production', 'country_exchange_history') }}
