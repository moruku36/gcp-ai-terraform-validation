# 学びとAWS / Azure比較

## 初期設計時点

| 観点 | AWS | Azure | GCP |
|---|---|---|---|
| Zone分離 | AZごとのSubnet | Subnetはリージョン、VMをZone指定 | Subnetはリージョン、Regional MIGがZone分散 |
| L7公開 | ALB | Application Gateway | Global External Application Load Balancer |
| Backend管理 | EC2 2台をTarget Group登録 | VM NICをBackend Pool登録 | Instance Template + Regional MIGをBackend登録 |
| Private egress | S3 Gateway Endpointでpackage取得 | NAT Gateway | Cloud NAT。外部package repositoryへ80/443のみ |
| Federation | IAM OIDC Provider + Role | Entra Federated Credential + Managed Identity | Workload Identity Pool/Provider + Service Account impersonation |
| State locking | S3 native lockfile | Blob lease | GCS backend標準locking |
| cleanup境界 | tagとState | Resource GroupとState | label・命名・State。Project全体削除は禁止 |

GCPはRegional MIGによる同一Template・Zone分散・autohealingが最も自然で、個別VM管理よりAIが望ましい構成を選びやすい。一方、WIFのPool、Provider、attribute condition、principal URI、Service Account IAMという分解は、AWS/Azure以上に文字列とscopeの検証が重要になる。

## Monitoring

- GCPは固定VM IDよりRegional MIGのcapacity、VM name prefix、Load Balancer metricを監視軸にすると自己修復と整合する。
- Health Check logのLogging resource typeと、log-based metricがMonitoringで公開するresource typeは一致しない場合がある。metric descriptorを確認する必要がある。
- Alert Policyはprovider schemaを通ってもMonitoring APIのduration/comparison制約で拒否される場合がある。部分apply後はState refreshし、未作成resourceだけのplanになっていることを確認する。
- MIG操作、managed metric収集、Incident評価はいずれも非同期である。障害試験はCompute実状態、時系列、Incidentを分けて観測する。
- 1台縮退では冗長性によりHTTP 200を維持でき、容量アラートのFired/Resolvedを安全に検証できた。
- AWS/Azureと同様、通知先は組織運用情報が必要になる境界であり、今回の公開検証ではAlert Policyまでをコード化した。
