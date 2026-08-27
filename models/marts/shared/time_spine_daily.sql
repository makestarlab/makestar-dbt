/*
  time_spine_daily
  ─────────────────────────────────────────────
  레거시 대응 : -
  grain       : 1일 1행
  
*/

{{ config(materialized='table') }}
select date_day
from unnest(generate_date_array(date(2019,1,1), date(2030,12,31))) as date_day
