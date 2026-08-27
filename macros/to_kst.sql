{#
  레거시 전반에 박혀 있던 datetime_add(col, interval 9 hour) 를 대체한다.
  타임존 정책이 바뀌면 이 매크로 한 곳만 고치면 된다.
#}
{% macro to_kst(column_name) %}
    datetime(timestamp({{ column_name }}), '{{ var("timezone") }}')
{% endmacro %}
