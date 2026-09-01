/*
  stg_production__country_codes
  -----------------------------------------------
  레거시 대응 : production.SPM_COUNTRY_CODE
  grain       : 원천과 동일
  주의        : 원본 컬럼명이 전부 대문자라 snake_case 로 리네임한다.
*/

select
    CNTRY_CD   as country_code,
    CNTRY_I18N as country_i18n
from {{ source('production', 'SPM_COUNTRY_CODE') }}
