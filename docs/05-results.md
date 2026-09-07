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
| root plan | 17 create、0 change、0 destroy。既存Resource変更なし |
| bootstrap plan | 13 create、0 change、0 destroy。State/WIF/IAM専用 |
| Cloud変更 | なし |

## 比較データ

推測せず、実行記録で確認できた数だけ更新する。

| 指標 | 現在値 |
|---|---:|
| root validate成功まで | 1回 |
| bootstrap validate成功まで | 1回 |
| root safe plan成功まで | 1回 |
| bootstrap safe plan成功まで | 4回（CLI解析失敗2、設定型エラー1、成功1） |
| apply成功まで | 未実施 |
| 発生した異なるエラー原因 | 4件（ローカル実行境界、`-chdir`、CLI引数解析、Terraform型） |
| 失敗したコマンド実行 | 5回（CLI引数解析は同じ原因で2回） |
| AI自律修正 | 4件 |
| 人間介入 | 0件 |
| IAM承認 | 0件 |
| GitHub Actions失敗 | 0件 |
| 意図しないTerraform drift | 0件 |
| destroy/recreate回避 | 0件 |
| No changes確認 | 0件 |

ADC未設定は既存gcloudログインの短時間tokenでread-only planだけ代替した。STS API未有効と高権限apply承認は次工程の既知の停止条件であり、現時点の失敗回数には含めていない。
