# 배포

## 1. 레포 생성 후 최초 푸시

```bash
cd makestar-dbt

git init -b main
git add .
git commit -m "chore: dbt 스캐폴드 - total_orders 리니지 기반 52개 모델"

# GitHub 에 빈 레포를 먼저 만든 뒤 (README 체크 해제)
git remote add origin git@github.com:<org>/makestar-dbt.git
git push -u origin main
```

HTTPS 를 쓴다면:

```bash
git remote add origin https://github.com/<org>/makestar-dbt.git
git push -u origin main
```

## 2. 이후 작업

```bash
git checkout -b feat/int-orders-classified
# ... 작업 ...
git add models/intermediate/orders/int_orders_classified.sql
git commit -m "feat: 매출 분류 CASE 트리 이식"
git push -u origin feat/int-orders-classified
```

## 3. 지속적 통합 (GitHub Actions)

`.github/workflows/ci.yml` 이 포함되어 있습니다.
레포 Settings → Secrets 에 `DBT_BIGQUERY_KEYFILE` (서비스 계정 JSON 전문) 을 등록하세요.

PR 마다 변경된 모델과 그 하류만 빌드하고 테스트합니다.
