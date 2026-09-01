/*
  int_catalog_items
  -----------------------------------------------
  레거시 대응 : datamart.vw_commerce_items_v2
  grain       : 상품 × 옵션 × 옵션콘텐츠 × SKU
  위험        : 🔴 mapper 의존성 제거 대상
  주의        : 레거시는 biz_type(이벤트 지역)을 order_biz_mapper_objects 에서 조인해왔다.
                카탈로그가 매출 분류 매퍼를 참조하는 순환 구조라 여기서는 끊는다.
                biz_type 이 필요한 하류 모델은 stg_manual__biz_mapper_objects 를 직접 참조할 것.
*/

with products as (
    select * from {{ ref('stg_mystarroom__products') }}
),
artists as (
    select * from {{ ref('stg_mystarroom__artists') }}
),
artist_companies as (
    select * from {{ ref('stg_mystarroom__artist_companies') }}
),
product_event_data as (
    select * from {{ ref('stg_mystarroom__product_event_data') }}
),
product_event_sales as (
    select * from {{ ref('stg_mystarroom__product_event_sales') }}
),
product_options as (
    select * from {{ ref('stg_mystarroom__product_options') }}
),
product_contents as (
    select * from {{ ref('stg_mystarroom__product_contents') }}
),
skus as (
    select * from {{ ref('stg_oms__skus') }}
),
sku_categories as (
    select * from {{ ref('stg_oms__sku_categories') }}
),
categories as (
    select * from {{ ref('stg_mystarroom__categories') }}
),

-- 레거시 pog 서브쿼리 : event_info.option_group_list / option_group_badge_list 를 풀어 옵션그룹명을 만든다.
option_group_names as (
    select distinct
        pe.id as product_event_id,
        cast(json_value(option_idx_item, '$') as int64) as option_idx,
        json_value(badge, '$.badge_name.ko') as product_option_group_name
    from product_event_data pe
    join unnest(json_extract_array(pe.event_info, '$.option_group_list')) as opt
    join unnest(json_extract_array(opt, '$.option_idx_list')) as option_idx_item
    join unnest(json_extract_array(pe.event_info, '$.option_group_badge_list')) as badge
        on cast(json_value(opt, '$.badge_idx') as int64) = cast(json_value(badge, '$.index') as int64)
),

-- 레거시 ea 서브쿼리 : 당첨자발표일 / 행사일
event_dates as (
    select
        pe.id as product_event_id,
        max(date(safe_cast(json_value(pe.event_info, '$.winner_announce_at') as datetime))) as announce_date,
        max(safe_cast(json_value(item, '$.date') as date)) as event_date
    from product_event_data pe
    join unnest(json_extract_array(pe.event_info, '$.event_holding_data')) as item
    group by pe.id
),

-- 레거시 ncm_product CTE : 상품 x 아티스트 x 이벤트 x 옵션 x 옵션콘텐츠
ncm_product as (
    select
        safe_cast(p.id as string) as product_id,
        p.product_code,
        json_value(p.title, '$.ko') as product_name,
        datetime_add(p.released_at, interval 9 hour) as product_release_at,
        safe_cast(aa.id as string) as artist_id,
        aa.name as artist_name,
        safe_cast(ac.id as string) as company_id,
        ac.name as company_name,
        cast(pes.product_event_id as string) as product_event_id,
        pe.code as product_event_code,
        json_value(pe.title, '$.ko') as product_event_name,
        case pe.product_event_type
            when 0 then '펀딩'
            when 1 then '이벤트'
            when 2 then '쇼핑' end as product_event_type,
        case pe.market_type
            when 0 then 'B2C&B2B'
            when 1 then 'B2B'
            when 2 then 'B2C' end as product_event_market_type,
        pe.purchase_limit_type,
        pes.sales_start_at,
        pes.sales_end_at,
        ea.announce_date,
        ea.event_date,
        safe_cast(json_value(peso, '$.index') as int64) + 1 as product_option_index,
        safe_cast(json_value(peso, '$.option_id') as string) as product_option_id,
        json_value(po.name, '$.ko') as product_option_name,
        ogn.product_option_group_name,
        json_value(peso, '$.price.krw') as product_option_price,
        json_value(peso, '$.b2b_price.krw') as product_option_b2b_price,
        json_value(peso, '$.sales_marketing_info.origin_price') as product_option_origin_price,
        json_value(peso, '$.sales_marketing_info.discount_rate') as product_option_discount_rate,
        json_value(poii, '$.index') as product_option_content_index,
        safe_cast(pc.id as string) as product_option_content_id,
        json_value(pc.title, '$.ko') as product_option_content_name,
        pc.content_type as product_option_content_type,
        json_value(poii, '$.earning_type') as product_option_content_earning_type,
        safe_cast(json_value(poii, '$.count') as int64) as product_option_content_qty,
        json_value(poii, '$.is_sales_count_base') as product_option_content_sales_base,
        pc.sku_code,
        pe.winning_category_id,
        json_value(pc.version_name, '$.ko') as opportunity_version,
        json_value(pc.title, '$.ko') as opportunity_title
    from products p
    left join artists aa on p.artist_id = aa.id
    left join artist_companies ac on p.company_id = ac.id
    left join product_event_data pe on p.id = pe.product_id
    left join product_event_sales pes on pe.id = pes.product_event_id
    left join unnest(json_extract_array(pes.option_list)) as peso
    left join product_options po on json_value(peso, '$.option_id') = safe_cast(po.id as string)
    left join unnest(json_extract_array(po.items_info)) as poii
    left join unnest(array(
        select json_extract_scalar(x)
        from unnest(json_extract_array(poii, '$.content_id_list')) x
    )) as poci
    left join product_contents pc on safe_cast(poci as int64) = pc.id
    left join option_group_names ogn
        on pe.id = ogn.product_event_id
        and safe_cast(json_value(peso, '$.index') as int64) = ogn.option_idx
    left join event_dates ea on pe.id = ea.product_event_id
    group by all
),

-- 레거시 ms 서브쿼리 : SKU 에 부모SKU / 카테고리명을 붙인다.
skus_enriched as (
    select
        s.sku_code,
        s.sku_name,
        s.sku_type,
        case when s.parent_sku_code = '' then s.sku_code else s.parent_sku_code end as parent_sku_code,
        case when s.parent_sku_code = '' then s.sku_name else parent.sku_name end as parent_sku_name,
        s.sku_name_component_1,
        s.sku_name_component_2,
        s.first_publish_yn,
        s.purchase_price,
        sc.category_code,
        sc.main_ctgr_cd,
        coalesce(main_cat.ctgr_nm, sc.ctgr_nm) as main_category_name,
        coalesce(mid_cat.ctgr_nm, sc.ctgr_nm) as mid_category_name,
        sc.ctgr_nm as category_name,
        s.production_company_product_code
    from skus s
    left join skus parent on s.parent_sku_code = parent.sku_code
    left join sku_categories sc on s.category_code = sc.category_code
    left join sku_categories main_cat on sc.main_ctgr_cd = main_cat.category_code
    left join sku_categories mid_cat on sc.mid_ctgr_cd = mid_cat.category_code
)

select
    n.product_id,
    n.product_code,
    n.product_name,
    n.product_release_at,
    n.artist_id,
    n.artist_name,
    n.company_id,
    n.company_name,
    n.product_event_id,
    n.product_event_code,
    n.product_event_name,
    n.product_event_type,
    n.product_event_market_type,
    n.purchase_limit_type,
    n.sales_start_at,
    n.sales_end_at,
    n.announce_date,
    n.event_date,
    c.name as event_category_name,
    n.product_option_index,
    n.product_option_id,
    n.product_option_name,
    n.product_option_group_name,
    n.product_option_price,
    n.product_option_b2b_price,
    n.product_option_origin_price,
    n.product_option_discount_rate,
    n.product_option_content_index,
    n.product_option_content_id,
    n.product_option_content_name,
    n.product_option_content_type,
    n.product_option_content_earning_type,
    n.product_option_content_qty,
    n.product_option_content_sales_base,
    se.sku_code,
    se.sku_name,
    se.sku_type,
    trim(se.sku_name_component_1) as sku_name_component_1,
    trim(se.sku_name_component_2) as sku_name_component_2,
    se.parent_sku_code,
    se.parent_sku_name,
    se.first_publish_yn,
    se.purchase_price,
    case when se.category_code = 'SCT002' or se.main_ctgr_cd = 'SCT002' then '음반' end as sku_is_album,
    case
        when trim(se.sku_name_component_1) in (select code from product_event_data where product_event_type = 1)
            then trim(se.sku_name_component_1)
        else null end as event_id,
    n.opportunity_version,
    n.opportunity_title,
    se.main_category_name,
    se.mid_category_name,
    se.category_name,
    se.production_company_product_code
from ncm_product n
left join skus_enriched se on n.sku_code = se.sku_code
left join categories c on n.winning_category_id = c.id
group by all
