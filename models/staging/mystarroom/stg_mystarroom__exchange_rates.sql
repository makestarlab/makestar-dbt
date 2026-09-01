/*
  stg_mystarroom__exchange_rates
  -----------------------------------------------
  레거시 대응 : pg_mystarroom_public.tb_commerce_exchange_rate
  grain       : 일자 1건
  주의        : 통화가 컬럼으로 펼쳐진 가로 형태다. 세로 변환은 intermediate 에서 한다.
                date 는 BigQuery 함수명과 겹치므로 rate_date 로 리네임한다.
*/

select
    id,
    date as rate_date,
    usd, jpy, krw, cny, eur, gbp,
    aed, aud, bhd, cad, chf, dkk, hkd, idr,
    kwd, myr, nok, nzd, sar, sek, sgd, thb
from {{ source('mystarroom', 'tb_commerce_exchange_rate') }}