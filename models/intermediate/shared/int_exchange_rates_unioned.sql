/*
  int_exchange_rates_unioned
  ─────────────────────────────────────────────
  레거시 대응 : vw_commerce_exchange_rate + external.country_exchange_rate_googlefinance
  grain       : 일자 × 통화
  
*/

-- 레거시는 대만만 googlefinance fallback(coalesce(exchange_rate, 41))을 쓴다.
-- 하드코딩 41 은 여기서 명시적 fallback 컬럼으로 노출할 것.
select
    date,
    currency,
    rate,
    'mystarroom' as rate_source
from {{ ref('stg_mystarroom__exchange_rates') }}
union all
select
    date, currency, rate, 'googlefinance' as rate_source
from {{ source('external', 'country_exchange_rate_googlefinance') }}
