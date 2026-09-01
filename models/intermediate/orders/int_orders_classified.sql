/*
  int_orders_classified
  -----------------------------------------------
  레거시 대응 : pre_total_orders 의 market_type/biz_type/channel_type CASE 트리
  grain       : 전 채널 주문 × 옵션 (행 수 불변)
  위험        : 🔴 최고 위험 - 분류 로직
  검증        : 레거시 CASE 트리를 열별로 그대로 옮겼다. 오버라이드 조인은
                int_orders_overridden 에서 별도로 붙인다. 행 수는 절대
                변하면 안 됨 → equal_rowcount 테스트 필수.
*/

-- 🔴 레거시 CASE 트리 약 90줄. 오버라이드 조인과 분리해서 여기에만 둔다.
--    참고: seed_biz_type_rules.csv 로 데이터화하는 것도 검토할 만하다.
--          (product_type, product_category) → (market_type, biz_type, channel_type)
select
    t.*,
    case
        when t.product_type = 'B' and t.product_category in ('상품', '차액지불') then 'B2B'
        when t.product_type = '포카앨범 제작' and t.product_category = '포카앨범 제작' then '포카앨범제작'
        when t.product_type = '앨범버디' and t.product_category = '상품' then '앨범버디'
        when t.product_type = 'G' and t.product_category = '상품' then '기타'
        when t.product_type = '앨범 유통/도매' and t.product_category = '앨범 유통/도매' then '기타'
        when t.product_type = '차액지불' and t.product_category = '차액지불' then '기타'
        else 'B2C'
    end as market_type,
    case
        when t.product_type = '리워드' and t.product_category = '리워드' then '한국(이벤트)'
        when t.product_type = 'B' and t.product_category in ('상품', '차액지불') then 'B2B'
        when t.product_type = 'C' and t.product_category = '상품' then '중국'
        when t.product_type = 'G' and t.product_category = '중국 팬클럽 자체 판매' then '중국'
        when t.product_type = '위챗미니' and t.product_category = '위챗미니' then '중국'
        when t.product_type = '웨이디엔' and t.product_category = '웨이디엔' then '중국'
        when t.product_type = '중국 오프라인매장' and t.product_category = '중국 오프라인매장' then '중국'
        when t.product_type = 'N' and t.product_category = '대만 오프라인 이벤트' then '대만'
        when t.product_type = '대만 오프라인매장' and t.product_category = '대만 오프라인매장' then '대만'
        when t.product_type = 'N' and t.product_category = '일본 오프라인 이벤트' then '일본'
        when t.product_type = '큐텐재팬' and t.product_category = '큐텐재팬' then '일본'
        when t.product_type = '타워레코드' and t.product_category = '타워레코드' then '일본'
        when t.product_type = '누에라(FC)' and t.product_category = '누에라(FC)' then '일본'
        when t.product_type = '누에라(공연)' and t.product_category = '누에라(공연)' then '일본'
        when t.product_type = '누에라(음반)' and t.product_category = '누에라(음반)' then '일본'
        when t.product_type = '일본 오프라인매장' and t.product_category = '일본 오프라인매장' then '일본'
        when t.product_type = '미주유럽 오프라인매장' and t.product_category = '미주유럽 오프라인매장' then '미주유럽'
        when t.product_type = 'G' and t.product_category = '상품' then '공동구매'
        when t.product_type = 'N' and t.product_category = '상품' then '쇼핑'
        when t.product_type = 'M' and t.product_category = '상품' then '쇼핑'
        when t.product_type = '포카앨범 제작' and t.product_category = '포카앨범 제작' then '포카앨범제작'
        when t.product_type = '앨범 유통/도매' and t.product_category = '앨범 유통/도매' then '앨범유통/도매'
        when t.product_type = '메이크스타샵' and t.product_category = '메이크스타샵' then '한국(매장)'
        when t.product_type = '앨범버디' and t.product_category = '상품' then '앨범버디'
        when t.product_type = '차액지불' and t.product_category = '차액지불' then '기타'
        when t.product_type = '스페이스상하이' and t.product_category = '스페이스상하이' then '중국'
        when t.product_type = '스페이스광저우' and t.product_category = '스페이스광저우' then '중국'
        when t.product_type = '스페이스선전' and t.product_category = '스페이스선전' then '중국'
        when t.product_type = '스페이스도쿄' and t.product_category = '스페이스도쿄' then '일본'
        when t.product_type = 'B2C 기타' and t.product_category = 'B2C 기타' then '기타'
    end as biz_type,
    case
        when t.data_source = '팬클럽 자체 링크 | 데이터 입력' then '팬클럽 자체 링크'
        when t.product_type = '리워드' and t.product_category = '리워드' then '메이크스타웹'
        when t.product_type = 'B' and t.product_category = '상품' then '메이크스타웹'
        when t.product_type = 'C' then '메이크스타웹'
        when t.product_type = 'G' and t.product_category = '중국 팬클럽 자체 판매' then '메이크스타웹'
        when t.product_type = '위챗미니' and t.product_category = '위챗미니' then '위챗미니프로그램'
        when t.product_type = 'N' and t.product_category = '중국 오프라인 이벤트' then '메이크스타웹'
        when t.product_type = '웨이디엔' and t.product_category = '웨이디엔' then '웨이디엔'
        when t.product_type = '중국 오프라인매장' and t.product_category = '중국 오프라인매장' and t.product_name = '대외팝업' then '대외팝업'
        when t.product_type = '중국 오프라인매장' and t.product_category = '중국 오프라인매장' then '오프라인매장'
        when t.product_type = 'N' and t.product_category = '대만 오프라인 이벤트' then '메이크스타웹'
        when t.product_type = '대만 오프라인매장' and t.product_category = '대만 오프라인매장' then '오프라인매장'
        when t.product_type = 'N' and t.product_category = '일본 오프라인 이벤트' then '메이크스타웹'
        when t.product_type = '큐텐재팬' and t.product_category = '큐텐재팬' then '큐텐재팬'
        when t.product_type = '타워레코드' and t.product_category = '타워레코드' then '타워레코드'
        when t.product_type = '누에라(FC)' and t.product_category = '누에라(FC)' then '누에라(FC)'
        when t.product_type = '누에라(공연)' and t.product_category = '누에라(공연)' then '누에라(공연)'
        when t.product_type = '누에라(음반)' and t.product_category = '누에라(음반)' then '누에라(음반)'
        when t.product_type = '일본 오프라인매장' and t.product_category = '일본 오프라인매장' then '오프라인매장'
        when t.product_type = '미주유럽 오프라인매장' and t.product_category = '미주유럽 오프라인매장' then '오프라인매장'
        when t.product_type = 'G' and t.product_category = '상품' then '메이크스타웹'
        when t.product_type = 'N' and t.product_category = '상품' then '메이크스타웹'
        when t.product_type = 'M' and t.product_category = '상품' then '메이크스타웹'
        when t.product_type = '포카앨범 제작' and t.product_category = '포카앨범 제작' then '외부거래'
        when t.product_type = '앨범 유통/도매' and t.product_category = '앨범 유통/도매' then '외부거래'
        when t.product_type = '메이크스타샵' and t.product_category = '메이크스타샵' then '오프라인매장'
        when t.product_type = '앨범버디' and t.product_category = '상품' then '앨범버디웹'
        when t.product_category = '차액지불' then '메이크스타웹'
        when t.product_type = '스페이스상하이' and t.product_category = '스페이스상하이' then '스페이스상하이'
        when t.product_type = '스페이스광저우' and t.product_category = '스페이스광저우' then '스페이스광저우'
        when t.product_type = '스페이스선전' and t.product_category = '스페이스선전' then '스페이스선전'
        when t.product_type = '스페이스도쿄' and t.product_category = '스페이스도쿄' then '스페이스도쿄'
        when t.product_type = 'B2C 기타' and t.product_category = 'B2C 기타' then '외부거래'
    end as channel_type
from {{ ref('int_orders_unioned') }} t
