{#
  주문 단위 배송비를 상품 결제액 비율로 배분한다.
  레거시: sum(shipping_revenue * product_revenue_portion)
#}
{% macro revenue_portion(amount_col, partition_col) %}
    safe_divide(
        {{ amount_col }},
        sum({{ amount_col }}) over (partition by {{ partition_col }})
    )
{% endmacro %}
