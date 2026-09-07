# GCP AI Terraform Validation

## 検証目的

自然言語の共通要件から、AI/CodexがGoogle Cloudネイティブな構成を設計し、Terraform、GitHub Actions、Workload Identity Federation、GCS Remote State、Monitoring、障害試験、cleanupまで安全に実装できるかを検証します。

AWS編・Azure編の単純なサービス名置換ではなく、Regional Managed Instance Group、Global External Application Load Balancer、GCP IAM、GCS Backend lockingなどの違いを記録します。

## アーキテクチャ

- Region: Tokyo (`asia-northeast1`)
- Compute: 2 Zoneへ均等配置するRegional Managed Instance Group、固定2台
- Frontend: Global External Application Load Balancer、HTTP 80のみ
- Backend: Ubuntu 24.04、Nginx、External IPなし、Internet SSHなし
- Egress: TCP 80/443だけをCloud NAT経由で許可
- State: 初期Local State、検証後に専用GCS Bucketへ移行予定
- CI/CD: GitHub OIDC + Workload Identity Federation、PR/Apply Identity分離
- Monitoring: Cloud Monitoring、Cloud Logging、Uptime Checkを必要最小限で追加予定

詳細は[アーキテクチャ](docs/02-architecture.md)を参照してください。

## 現在の進捗

- [x] ローカル環境、認証状態、選択中Project、Region/Zone、既存リソース境界を匿名化して確認
- [x] root / bootstrap Terraform初期実装
- [x] `terraform fmt`、`terraform init -backend=false`、`terraform validate`
- [x] 既存gcloudログインの短時間tokenによるread-only plan（root 17 create、bootstrap 13 create、destroy / replaceなし）
- [ ] Web基盤applyとHTTP 200
- [ ] GCS Remote State移行とlocking試験
- [ ] GitHub Actions / WIF実動作
- [ ] Monitoringと障害試験
- [ ] cleanupと残存0確認

> 2026-09-07時点ではGoogle Cloudへの変更は行っていません。実Project ID、Project Number、Service Account email、Credential、Public IPはGitへ保存しません。STS API有効化とbootstrap/root applyは人間承認待ちです。

## ローカル検証

```powershell
gcloud auth application-default login
$env:TF_VAR_project_id = gcloud config get-value project
terraform init -backend=false
terraform fmt -check -recursive
terraform validate
terraform plan -out=tfplan
```

planを確認するまでapplyしません。Remote State移行後は`backend.tf.example`を基に、実Bucket名をコマンド引数または安全なCI設定から渡します。

## ドキュメント

- [検証シナリオ](docs/01-scenario.md)
- [GCPアーキテクチャ](docs/02-architecture.md)
- [Terraform実装](docs/03-implementation.md)
- [トラブルシューティング](docs/04-troubleshooting.md)
- [実行結果・集計](docs/05-results.md)
- [学びとAWS/Azure比較](docs/06-lessons-learned.md)
- [CI/CD・WIF・Remote State](docs/07-cicd-oidc-remote-state.md)
- [Monitoring](docs/08-monitoring.md)
