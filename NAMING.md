# 네이밍 규칙

제가 붙인 이름은 전부 제안입니다. `rename.yml` 에 새 이름을 적고 `python rename.py` 를
돌리면 파일명 · `ref()` · yml 이 한 번에 바뀝니다.

## 현재 적용한 규칙

| 층 | 형식 | 예 |
|---|---|---|
| staging | `stg_<소스시스템>__<엔티티복수형>` | `stg_mystarroom__orders` |
| intermediate | `int_<주제>_<상태/동사>` | `int_orders_classified` |
| fact | `fct_<사건복수형>` | `fct_orders` |
| dimension | `dim_<개체단수형>` | `dim_user` |
| bridge | `bridge_<A>_<B>` | `bridge_order_event` |

- staging 의 `__`(더블 언더스코어)는 소스 시스템과 엔티티의 구분자입니다. dbt 관례입니다.
- 모델 이름은 **프로젝트 전체에서 유니크**해야 합니다. 폴더가 달라도 같은 이름은 불가합니다.
- `shared/` 아래는 접두어를 붙이지 않습니다. 서비스가 늘어도 그대로 씁니다.
- 두 서비스에서 같은 이름이 필요해지는 시점에만 `commerce__` / `svc2__` 를 붙입니다.

## 바꿀 만한 후보

제가 임의로 정해서 취향이 갈릴 만한 것들입니다.

| 현재 | 대안 | 비고 |
|---|---|---|
| `int_orders_classified` | `int_orders_segmented` / `int_orders_typed` | 매출 분류 CASE 트리 |
| `int_orders_overridden` | `int_orders_mapped` / `int_orders_adjusted` | 매퍼 오버라이드 적용 |
| `int_catalog_items` | `int_product_sku_lookup` | 원안의 이름 |
| `int_catalog_option_sales` | `int_pool_composition` | 풀 구성 정보 |
| `int_album_unit_allocation` | `int_album_qty_allocated` | |
| `bridge_order_event` | `bridge_order_offer` | 오퍼/이벤트 용어 통일 여부 |
| `stg_manual__*` | `stg_ops__*` / `stg_sheet__*` | 수기입력 소스 그룹명 |
| `dw_legacy` (소스) | `legacy` / `datamart` | |

## 소스 이름도 바꿀 수 있습니다

`models/staging/_src_*.yml` 의 `- name:` 을 고치고, `source('<이름>', ...)` 호출부를
같이 바꾸면 됩니다. `rename.py` 는 모델만 다루므로 소스는 수동으로 해주세요.
