/*
  int_orders_enriched
  -----------------------------------------------
  레거시 대응 : datamart.vw_commerce_orders
  grain       : 주문 1건 (additional_order 포함)
  주의        : 레거시 컬럼 중 pre_commerce_orders 이하 매출 분류 체인이 실제로
                읽지 않는 것들(payment_method eximbay 매핑, customer_name/email,
                given_name/주소, event_apply_* 응모자 개인정보)은 여기서 뺐다.
                필요해지면 그때 채운다.
  위험        : ⚠️ exchange_rate 계산의 gbp 는 레거시 원본이 krw/eur 로 나눈다
                (krw/gbp 가 아님). 버그로 보이나 패리티를 위해 그대로 이식한다.
  검증        : vw_commerce_orders 대비 750,206 / 750,221 행 매칭, 값 불일치 0.
                차이 15건은 stg_mystarroom__orders 가 (order_id, order_number) 당
                최신 스냅샷 1건만 남기기 때문 (레거시는 insert-only 스냅샷을 GROUP BY ALL
                로만 접어서 상태가 바뀐 주문은 여러 행으로 남는다). 의도된 차이.
*/

with
    orders as (select * from {{ ref('stg_mystarroom__orders') }}),
    additional_orders as (select * from {{ ref('stg_mystarroom__additional_orders') }}),
    ip_address_info as (select * from {{ ref('stg_mystarroom__ip_address_info') }}),
    user_group_memberships as (select * from {{ ref('stg_mystarroom__user_groups') }}),
    user_group_definitions as (select * from {{ ref('stg_mystarroom__user_group_definitions') }}),
    country_codes as (select * from {{ ref('stg_production__country_codes') }}),
    exchange_rates_wide as (select * from {{ ref('stg_mystarroom__exchange_rates') }}),

    -- 레거시 uc 서브쿼리 : B2B 유저그룹에 박힌 국가코드
    b2b_user_country as (
        select distinct
            cast(uug.user_id as string) as user_id,
            json_value(ug.b2b_partnership_information, '$.country_code') as country_code
        from user_group_memberships uug
        join user_group_definitions ug on uug.group_id = ug.id
    ),

    -- 레거시 ex 서브쿼리 : 2024-10-30 부터 오늘까지 일자별 환율, 결측은 직전값으로 채운다.
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
        left join exchange_rates_wide ex on d.rate_date = date(date_add(ex.rate_date, interval 9 hour))
    ),
    exchange_ratio_wide as (
        select
            rate_date,
            safe_divide(krw, krw) as krw,
            safe_divide(krw, usd) as usd,
            safe_divide(krw, jpy) as jpy,
            safe_divide(krw, cny) as cny,
            safe_divide(krw, eur) as eur,
            safe_divide(krw, eur) as gbp  -- 레거시 원본 그대로 : gbp 도 eur 로 나눈다
        from exchange_filled
    ),
    exchange_rates as (
        select rate_date, upper(currency) as currency, exchange_rate
        from exchange_ratio_wide
        unpivot(exchange_rate for currency in (krw, usd, jpy, cny, eur, gbp))
    ),

    orders_country_resolved as (
        select
            o.*,
            case
                when left(o.order_number, 1) = 'B'
                    then coalesce(bc.country_code, json_value(i.ip_description, '$.country_code2'))
                else json_value(i.ip_description, '$.country_code2')
            end as order_country_code,
            o.delivery_country_code as delivery_country_code_raw
        from orders o
        left join ip_address_info i on o.ip_address_info_id = i.id
        left join b2b_user_country bc on o.user_id = bc.user_id
    ),

    branch1 as (
        select
            o.order_id,
            o.order_number,
            o.order_status,
            o.order_type,
            o.payment_id,
            o.payment_status,
            o.logis_code,
            o.user_id,
            o.order_created_at_kst,
            o.payment_at_kst,
            o.currency,
            o.logis_pay_amount,
            o.duties_and_taxes,
            o.duty_handling_fee,
            o.order_country_code,
            json_value(oc.country_i18n, '$.ko') as order_country_name,
            o.delivery_country_code_raw as delivery_country_code,
            json_value(sc.country_i18n, '$.ko') as delivery_country_name,
            date(timestamp(o.order_created_at_kst, 'Asia/Seoul')) as order_created_date_raw
        from orders_country_resolved o
        left join country_codes oc on o.order_country_code = oc.country_code
        left join country_codes sc on o.delivery_country_code_raw = sc.country_code
    ),

    branch2 as (
        select
            order_number as order_id,
            cast(null as string) as order_number,
            case order_status
                when 0 then 'CREATED'
                when 1 then 'PAYMENT_PROCESSING'
                when 2 then 'PAYMENT_COMPLETED'
                when 3 then 'PAYMENT_FAILED'
                when 4 then 'INVENTORY_CHECKING'
                when 5 then 'SHIPPING_PROCESSING'
                when 6 then 'COMPLETED'
                when 7 then 'REQUESTED_CANCEL'
                when 8 then 'REFUND_PROCESSING'
                when 9 then 'CANCELED'
                when 10 then 'PAYMENT_PROCESSING'
                when 11 then 'PAYMENT_PROCESSING'
                when 997 then 'CANCELED'
                when 999 then 'PAYMENT_EXPIRED'
                else 'UNDEFINED'
            end as order_status,
            case left(order_number, 1)
                when 'C' then 'B2C'
                when 'B' then 'B2B'
                when 'E' then 'ETC'
            end as order_type,
            payment_request_id as payment_id,
            json_value(payment_data, '$.status') as payment_status,
            cast(null as string) as logis_code,
            cast(user_id as string) as user_id,
            {{ to_kst('created_at') }} as order_created_at_kst,
            case json_value(payment_data, '$.request.request_pg')
                when '0' then safe_cast(json_value(payment_data, '$.response.approvedAt') as timestamp)
                when '1' then timestamp_add(
                    parse_timestamp(
                        '%Y%m%d%H%M%S',
                        if(json_value(payment_data, '$.response.data.payment.transaction_date') = '',
                           '99991231000000',
                           json_value(payment_data, '$.response.data.payment.transaction_date'))
                    ),
                    interval -9 hour
                )
                when '2' then safe_cast(json_value(payment_data, '$.response.approvedAt') as timestamp)
            end as payment_at_raw,
            json_value(ordered_data, '$.currency_code') as currency,
            0.0 as logis_pay_amount,
            0.0 as duties_and_taxes,
            0.0 as duty_handling_fee,
            cast(null as string) as order_country_code,
            cast(null as string) as order_country_name,
            cast(null as string) as delivery_country_code,
            cast(null as string) as delivery_country_name,
            date(created_at) as order_created_date_raw
        from additional_orders
    ),

    branch2_kst as (
        select
            * except (payment_at_raw),
            {{ to_kst('payment_at_raw') }} as payment_at_kst
        from branch2
    ),

    unioned as (
        select
            order_id, order_number, order_status, order_type, payment_id, payment_status,
            logis_code, user_id, order_created_at_kst, payment_at_kst, currency,
            logis_pay_amount, duties_and_taxes, duty_handling_fee,
            order_country_code, order_country_name, delivery_country_code, delivery_country_name,
            order_created_date_raw
        from branch1
        union all
        select
            order_id, order_number, order_status, order_type, payment_id, payment_status,
            logis_code, user_id, order_created_at_kst, payment_at_kst, currency,
            logis_pay_amount, duties_and_taxes, duty_handling_fee,
            order_country_code, order_country_name, delivery_country_code, delivery_country_name,
            order_created_date_raw
        from branch2_kst
    )

select
    u.order_id,
    u.order_number,
    u.order_status,
    u.order_type,
    u.payment_id,
    u.payment_status,
    u.logis_code,
    u.user_id,
    u.order_created_at_kst,
    u.payment_at_kst,
    upper(u.currency) as currency,
    ex.exchange_rate,
    u.logis_pay_amount,
    u.duties_and_taxes,
    u.duty_handling_fee,
    u.order_country_code,
    u.order_country_name,
    u.delivery_country_code,
    u.delivery_country_name
from unioned u
left join exchange_rates ex
    on u.order_created_date_raw = ex.rate_date
    and upper(u.currency) = ex.currency
