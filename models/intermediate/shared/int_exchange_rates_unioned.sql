/*
  int_exchange_rates_unioned
  -----------------------------------------------
  레거시 대응 : vw_commerce_exchange_rate + external.country_exchange_rate_googlefinance
  grain       : 일자 x 통화
  주의        : rate 는 "1 통화당 KRW" 비율이다 (원본값이 아니다).
                레거시는 2025-03-01 을 기준으로 소스가 바뀐다.
                  - 그 이전: production.country_exchange_history 를 KRW 기준으로 셀프조인해 평균
                  - 그 이후: tb_commerce_exchange_rate 를 2024-10-30 부터 직전값으로 채운 뒤
                            krw / 통화 로 비율을 만든다.
                대만은 이 표에 없다. googlefinance 를 fallback 으로 쓰고
                그마저 없으면 41 을 하드코딩한다 (레거시 pre_total_orders offline CTE 참고).
                판단은 하류로 미룬다.
*/

{{ config(materialized='view') }}

with exchange_history as (
    select * from {{ ref('stg_production__exchange_history') }}
),

mystarroom_wide as (
    select * from {{ ref('stg_mystarroom__exchange_rates') }}
),

-- 2025-03-01 이전 : country_exchange_history 를 KRW 기준 셀프조인
legacy_history as (
    select
        date(date_add(e1.write_date, interval 9 hour)) as rate_date,
        upper(e2.currency) as currency,
        avg(e1.price / e2.price) as rate,
        'country_exchange_history' as rate_source
    from exchange_history e1
    join exchange_history e2 on e1.write_date = e2.write_date
    where e1.currency = 'KRW'
    group by all
    having rate_date < '2025-03-01'
),

-- 2025-03-01 이후 : tb_commerce_exchange_rate, 결측은 직전값으로 채운 뒤 비율 계산
exchange_dates as (
    select date_list as rate_date
    from unnest(generate_date_array('2024-10-30', current_date('Asia/Seoul'))) as date_list
),
exchange_filled as (
    select
        d.rate_date,
        last_value(ex.krw ignore nulls) over (order by d.rate_date asc) as krw,
        last_value(ex.usd ignore nulls) over (order by d.rate_date asc) as usd,
        last_value(ex.jpy ignore nulls) over (order by d.rate_date asc) as jpy,
        last_value(ex.cny ignore nulls) over (order by d.rate_date asc) as cny,
        last_value(ex.eur ignore nulls) over (order by d.rate_date asc) as eur,
        last_value(ex.gbp ignore nulls) over (order by d.rate_date asc) as gbp
    from exchange_dates d
    left join mystarroom_wide ex on d.rate_date = date(date_add(ex.rate_date, interval 9 hour))
),
mystarroom_ratio as (
    select
        rate_date,
        safe_divide(krw, krw) as krw,
        safe_divide(krw, usd) as usd,
        safe_divide(krw, jpy) as jpy,
        safe_divide(krw, cny) as cny,
        safe_divide(krw, eur) as eur,
        safe_divide(krw, gbp) as gbp
    from exchange_filled
),
mystarroom_current as (
    select rate_date, upper(currency) as currency, rate, 'mystarroom' as rate_source
    from mystarroom_ratio
    unpivot(rate for currency in (krw, usd, jpy, cny, eur, gbp))
    where rate_date >= '2025-03-01'
),

googlefinance as (
    select
        date            as rate_date,
        upper(currency) as currency,
        exchange_rate   as rate,
        'googlefinance' as rate_source
    from {{ source('external', 'country_exchange_rate_googlefinance') }}
)

select * from legacy_history
union all
select * from mystarroom_current
union all
select * from googlefinance
