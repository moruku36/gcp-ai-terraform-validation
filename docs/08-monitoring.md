# Monitoring

## 設計

ネイティブメトリクス、外形監視、Health Check状態遷移ログだけを使う。Ops Agent、Log Analytics、BigQuery export、専用Log bucket、Dashboardは追加しない。

| 要件 | データ源 | Alert条件 |
|---|---|---|
| Web停止 | Uptime Check `check_passed` | 2地点以上の失敗が2分継続 |
| Backend / VM capacity異常 | `compute.googleapis.com/instance_group/size` | Regional MIGが2台未満で2分継続 |
| Health Check異常 | Health Check状態遷移log-based metric | `UNHEALTHY`または`TIMEOUT`が1件以上で1分継続 |
| CPU高負荷 | `compute.googleapis.com/instance/cpu/utilization` | 5分平均が80%超で5分継続 |
| HTTP 5xx増加 | `loadbalancing.googleapis.com/https/request_count` | 5分間に5件以上 |

Uptime CheckはHTTP 80で2xxとページ識別文字列を検証する。MIGとHealth Checkの併用により、個別VM IDを固定せず、VM停止、自己修復、Backend異常を追跡できる。

通知先は検証要件で指定されていないためNotification Channelを作らない。Alert PolicyとIncidentはCloud Monitoringで確認できる。本番導入時は組織管理の通知先を追加する。

## ログ

既存Terraformは次を既に有効化していたため、Monitoring追加による既存リソース変更はない。

- Global External Application Load Balancer access log: sample rate 100%
- Load Balancer Health Check: Backend状態遷移log
- 保存先: project標準Cloud Logging `_Default` bucket
- 保持期間: 標準30日

Health Check logは状態遷移時だけ生成され、endpoint削除時には必ずしも生成されない。このためBackend capacity alertも併用する。

## コスト

- Uptime Check: 月100万executionまでのfree allotment内を想定
- Google Cloud標準メトリクス: 非課金メトリクスを使用
- Logging: Health Check状態遷移と低トラフィックのLB access logだけで、少量取り込みを想定
- Alerting: 公式価格では課金開始は2027年9月1日より前には行われない予定。5 metric referenceに限定
- 長期保持、Log export、Ops Agent、Synthetic Monitorは不採用

短時間の検証では監視増分は実質的に小さい見込みだが、実額はトラフィック量とBilling条件に依存する。

## AWS / Azureとの違い

- AWS編のCloudWatch Alarmに対し、GCPはUptime Check、managed-service metrics、Logging metricを組み合わせる。
- Azure編のApplication Gateway metric alertに対し、GCP Health Checkは状態遷移ログが調査の中心になる。
- Regional MIGがVMを自動修復するため、固定VM IDではなくMIG sizeとinstance-name prefixで監視する。
- GCPの外形監視はGoogle分散checkerの結果を集約でき、単一Region内部だけの監視にしない。

## Terraform事前確認

- `terraform fmt -check`: 成功
- `terraform validate`: 成功
- root plan: 7 create、0 change、0 destroy
- 既存Web、Network、Identity、State resourceの更新・置換: なし

## 初回applyと修正

初回main applyは7件中5件を作成後、Monitoring APIのcondition制約により2件で停止した。IAM不足ではなかったため権限追加は行っていない。

- `evaluation_missing_data`を使うconditionのdurationを0秒から60秒へ修正
- 未対応の`COMPARISON_GE`を、同義の`COMPARISON_GT`とthreshold 4へ修正
- 部分適用後のState refreshを実施
- 修正plan: 未作成Alert Policy 2 create、0 change、0 destroy

再applyと障害試験結果は実行後に追記する。
