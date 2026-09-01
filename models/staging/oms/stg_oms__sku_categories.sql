/*
  stg_oms__sku_categories
  -----------------------------------------------
  레거시 대응 : pg_oms_public.mst_sku_category
  grain       : 원천과 동일
*/

select
    category_code,
    ctgr_div,
    main_ctgr_cd,
    mid_ctgr_cd,
    ctgr_nm,
    ctgr_desc,
    hs_code,
    description_for_customs,
    ctgr_order,
    reg_id,
    reg_dttm,
    mod_id,
    mod_dttm,
    record_yn,
    bulk_purchase_condition_yn,
    weight,
    length,
    width,
    height,
    volume,
    max_box_quantity,

    -- 메타는 맨 뒤
    datastream_metadata
from {{ source('oms', 'mst_sku_category') }}
