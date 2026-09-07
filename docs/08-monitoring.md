# Monitoring

## 採用予定の最小構成

| 要件 | データ源 | 初期条件案 |
|---|---|---|
| Web停止 | Uptime Check `check_passed` | 2地点以上で連続失敗、5分 |
| Backend異常 | Health Check状態遷移log-based metric | `HEALTHY -> UNHEALTHY`が1件以上 |
| VM / capacity異常 | `compute.googleapis.com/instance_group/size` | MIG sizeが2未満、5分 |
| CPU高負荷 | `compute.googleapis.com/instance/cpu/utilization` | 80%超、5分 |
| HTTP 5xx | `loadbalancing.googleapis.com/https/request_count` | 5分で5件以上 |

## ログ

- Backend Serviceのaccess logを有効化
- Load Balancer Health Checkの状態遷移logを有効化
- Cloud NATはERRORS_ONLY
- Firewall ingressはmetadata付きlogging
- 専用Log bucketやLog Analytics相当は作らず、標準Cloud Loggingの保持とfree allotmentを利用

## コスト判断

Uptime Check実行は月100万回までfree allotmentがあり、この検証は十分範囲内。Cloud Loggingも少量のためfree allotment内を想定する。2026-09-01以降、metric参照を持つAlert Policyには月額課金があるため、重複Policyを避けて5系統以内とする。実装前にmetric filterと課金条件を再確認する。

障害試験はRegional MIGの1 instanceを停止またはNginxを停止し、HTTP 200継続、Backend異常、autohealing、Alert Fired/Resolvedを確認する。Firewallの緩和は行わない。
