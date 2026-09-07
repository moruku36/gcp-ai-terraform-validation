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
| API | 必要候補のうちSTS APIだけ未有効 |
| Terraform | root / bootstrapともfmt、init、validate成功 |
| Cloud変更 | なし |

## 比較データ

推測せず、実行記録で確認できた数だけ更新する。

| 指標 | 現在値 |
|---|---:|
| root validate成功まで | 1回 |
| bootstrap validate成功まで | 1回 |
| safe plan成功まで | 未実施 |
| apply成功まで | 未実施 |
| 発生エラー | 2件（ローカル実行境界、PowerShell引数） |
| AI自律修正 | 2件 |
| 人間介入 | 0件 |
| IAM承認 | 0件 |
| GitHub Actions失敗 | 0件 |
| 意図しないTerraform drift | 0件 |
| destroy/recreate回避 | 0件 |
| No changes確認 | 0件 |

ADC未設定とSTS API未有効は次工程の既知の停止条件であり、現時点の失敗回数には含めていない。
