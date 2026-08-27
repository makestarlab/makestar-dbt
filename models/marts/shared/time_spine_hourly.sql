/*
  time_spine_hourly
  ─────────────────────────────────────────────
  레거시 대응 : -
  grain       : 1시간 1행
  
*/

{{ config(materialized='table') }}
select date_hour
from unnest(generate_timestamp_array(
    timestamp('2019-01-01 00:00:00'),
    timestamp('2030-12-31 23:00:00'),
    interval 1 hour
)) as date_hour
