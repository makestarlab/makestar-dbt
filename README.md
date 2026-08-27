# makestar-dbt

`datamart.total_orders` 를 dbt 로 재구성하는 프로젝트입니다.
레거시 6단 파이프라인을 실측 분석해 52개 모델 / 47개 소스 테이블로 펼친 스캐폴드입니다.

## 레거시 리니지 (실측)

```
pg_mystarroom_public.tb_commerce_order  (JSONB)
  └─ MERGE, 2.5분 주기, insert-only          ← dbt 밖. source 로만 사용
[1] datamart.tb_commerce_orders_flattened
[2] datamart.vw_commerce_orders / vw_commerce_order_items
[3] datamart.pre_commerce_orders            리워드 / 쇼핑 / 차액지불 3개 UNION
[4] datamart.pre_total_orders               + 웨이디엔 + 오프라인 9개 + 앨범버디
                                            + 수기 3종 + archived
                                            → 분류 CASE → 오버라이드 2단
[5] datamart.total_orders                   WHERE market_type != '제외'
```

## 2단계 전환 전략

**Phase 1 (지금)** — `fct_orders` 가 레거시 `total_orders` 를 감싸는 얇은 래퍼입니다.
지표 정의(`models/semantic/`)를 먼저 고정해 Redash 의 흩어진 계산식을 통일합니다.

**Phase 2** — `int_orders_*` 를 채워 넣고 `fct_orders` 의 `from` 절만 교체합니다.
`tests/assert_orders_parity_*.sql` 로 행 수와 월별 매출을 레거시와 대조합니다.
**다운스트림은 아무것도 바뀌지 않습니다.**

## 위험 지점 4개

| 모델 | 문제 |
|---|---|
| `int_orders_overridden` | 🔴 레거시가 `OR` 3개로 조인 → 행 복제, 매출 과다 |
| `int_catalog_option_sales` | 🔴 `sum(sales_qty)` 가 풀 전체를 더함 → 앨범수량 2.69배 |
| `int_catalog_event_resolution` | ⚠️ event_id 를 SKU명 문자열 파싱으로 판정 |
| 전역 | ⚠️ `interval 9 hour` 하드코딩 → `{{ to_kst() }}` 매크로로 대체 |

## 시작하기

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install "dbt-bigquery>=1.9" "dbt-metricflow[bigquery]"

cp profiles.yml.example ~/.dbt/profiles.yml   # dataset 을 본인 것으로 수정
gcloud auth application-default login

dbt deps
dbt parse                  # 이름 매칭 · YAML 문법 검증
dbt ls                     # 52개 모델이 잡히는지 확인
dbt build -s tag:staging   # staging 만 먼저
```

## 자주 쓰는 명령

```bash
dbt build -s marts                     # 마트만
dbt build -s +fct_orders               # fct_orders 와 그 상류 전부
dbt build -s int_orders_overridden     # 위험 모델 단독 + 테스트
dbt test  -s tag:marts
dbt source freshness

dbt parse && mf validate-configs       # 시맨틱 레이어 검증
mf query --metrics gmv --group-by metric_time__month --explain
```

## 모델 이름 바꾸기

`rename.yml` 오른쪽에 원하는 이름을 적고:

```bash
python rename.py          # 적용
python rename.py --undo   # 되돌리기
dbt parse                 # 확인
```

자세한 규칙은 `NAMING.md` 를 보세요.
