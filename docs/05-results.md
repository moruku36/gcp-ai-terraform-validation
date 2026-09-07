# 実行結果

## 2026-09-07 初期レビュー

| 項目 | 匿名化した結果 |
|---|---|
| gcloud | 583.0.0 |
| Terraform | 1.9.8 |
| gcloud Identity | 2件登録、active Identityあり |
| 選択中Project | 設定済み、ACTIVE、Billing有効 |
| 日本Region | Tokyo / OsakaともUP、各3 Zone UP |
| 既存境界 | Compute 0、Storage Bucket 0、WIF Pool 0。default VPC 1と既存Service Account 2を保護対象として記録 |
| API | STSを含む必要APIを有効化済み |
| Terraform | root / bootstrapともfmt、init、validate成功 |
| root plan | 17 create、0 change、0 destroy。既存Resource変更なし |
| bootstrap plan | 13 create、0 change、0 destroy。State/WIF/IAM専用 |
| root apply | 17 added、0 changed、0 destroyed。VM 2台RUNNING、Backend 2台HEALTHY、HTTP 200 |
| bootstrap apply | 13 added、0 changed、0 destroyed。State Bucket、WIF、PR/Apply Identity、最小権限Roleを作成 |
| Remote State | GCSへ移行済み。backup SHA-256一致、lineage一致、17リソース、移行後No changes |
| Apply SA binding | VM実行Identityに対する`serviceAccountUser` 1件だけを追加 |

## 比較データ

推測せず、実行記録で確認できた数だけ更新する。

| 指標 | 現在値 |
|---|---:|
| root validate成功まで | 1回 |
| bootstrap validate成功まで | 1回 |
| root safe plan成功まで | 1回 |
| bootstrap safe plan成功まで | 4回（CLI解析失敗2、設定型エラー1、成功1） |
| apply成功まで | root 1回、bootstrap 1回 |
| 発生した異なるエラー原因 | 8件（既存5件＋Monitoring API condition制約2件＋log-based metric resource mapping 1件） |
| 失敗したコマンド実行 | 追加集計中（同一CLI引数解析の再発を含む） |
| AI自律修正 | 7件（Monitoring関連3件を含む） |
| 人間介入 | 1件（Google Cloudへの書込み承認） |
| IAM承認 | 1件（既存Owner Identityによるbootstrap実行の承認。恒久Credentialは作成せず） |
| GitHub Actions失敗 | 3 attempt（Monitoring apply。IAM拡張なしで原因修正） |
| 意図しないTerraform drift | 0件 |
| destroy/recreate回避 | 0件 |
| No changes確認 | 5件以上（記録から確認できる範囲。Monitoring復旧後を含む） |

ADC未設定は既存gcloudログインの短時間tokenでplan/applyを実施した。tokenは環境変数だけで利用し、ログ・ファイル・GitHubへ保存していない。GitHub Actions実動作以降の集計は完了後に更新する。

## GitHub OIDC / Apply workflow結果

- PR用・Apply用ともstable GitHub owner/repository IDを含むexact subjectでWIF認証成功
- Applyはmain限定の`terraform-production` Environmentから実行
- 長期Credential、Service Account Key、権限追加なし
- GCS Remote State初期化成功
- root planはNo changes
- saved planのapplyは`0 added / 0 changed / 0 destroyed`
- GCS backendは標準lockingを有効にしたまま完了
- 一時OIDC claim確認jobは削除済み

## Monitoring結果

- Uptime Check 1、Alert Policy 5、Health Check log-based metric 1をTerraform管理
- 既存Load Balancer access logとHealth Check logを標準Cloud Loggingへ保存
- PR planは既存Web resourceの変更・置換なし
- main applyはAPI入力制約を2段階で修正後に成功。最終追加は1件のみ
- 障害試験ではMIGを2台から1台へ一時縮小してもHTTP 200を継続
- 容量低下metric、Incident Open（Fired）、2台Healthy復旧、Incident Closedを確認
- 復旧後のroot planはNo changes
- MonitoringのためのIAM追加、長期Credential、Service Account Keyはなし
