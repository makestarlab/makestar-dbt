/*
  int_exchange_rates_unioned
  -----------------------------------------------
  레거시 대응 : vw_commerce_exchange_rate + external.country_exchange_rate_googlefinance
  grain       : 일자 x 통화
  주의        : tb_commerce_exchange_rate 는 통화가 컬럼으로 펼쳐진 가로 형태다.
                UNPIVOT 으로 세로로 돌려야 다른 소스와 합칠 수 있다.
                레거시는 대만만 googlefinance 를 fallback 으로 쓰고
                그마저 없으면 41 을 하드코딩한다.
                여기서는 소스를 구분해 두고 fallback 판단은 하류로 미룬다.
*/

{{ config(materialized='view') }}

with mystarroom_wide as (
    select * from {{ ref('stg_mystarroom__exchange_rates') }}
),

mystarroom_long as (
    select
        date(rate_date)   as rate_date,
        upper(currency)   as currency,
        rate,
        'mystarroom'      as rate_source
    from mystarroom_wide
    unpivot (
        rate for currency in (
            usd, jpy, krw, cny, eur, gbp, aed, aud, bhd, cad, chf,
            dkk, hkd, idr, kwd, myr, nok, nzd, sar, sek, sgd, thb
        )
    )
),

googlefinance as (
    select
        date              as rate_date,
        upper(currency)   as currency,
        exchange_rate     as rate,
        'googlefinance'   as rate_source
    from {{ source('external', 'country_exchange_rate_googlefinance') }}
)

select * from mystarroom_long
union all
select * from googlefinance