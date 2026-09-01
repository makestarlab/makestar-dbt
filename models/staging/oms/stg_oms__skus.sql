/*
  stg_oms__skus
  -----------------------------------------------
  레거시 대응 : pg_oms_public.mst_sku
  grain       : 원천과 동일
  위험        : ⚠️ mst_sku 직발주 변형 SKU 중복
*/

select
    sku_code,
    sku_name,
    sku_type,
    parent_sku_code,
    distribution_code,
    category_code,
    first_publish_yn,
    first_publish_sku_code,
    wms_code,
    sku_description,
    price,
    purchase_price,
    issue_date,
    weight,
    length,
    width,
    height,
    volume,
    thumbnail,
    full_image,
    manufacturer,
    ordering_organization,
    first_week_closing_date,
    last_order_closing_date,
    use_yn,
    reg_id,
    taxation_yn,
    reg_dttm,
    mod_id,
    mod_dttm,
    sku_name_component_1,
    sku_name_component_2,
    virtual_child_sku_count,
    child_sku_count_in_use,
    ordering_organization_int,
    artist_id,
    vendor_id,
    production_company_id,
    production_company_product_code,
    vendor_pack_size,
    production_company_product_code_normalized,
    sku_code_normalized,
    sku_name_normalized,
    distributor_pre_order_deadline,
    distributor_final_order_deadline,
    returnable_yn,
    returnable_memo,
    purchase_order_allowed_yn,
    purchase_order_memo,

    -- 메타는 맨 뒤
    datastream_metadata
from {{ source('oms', 'mst_sku') }}
