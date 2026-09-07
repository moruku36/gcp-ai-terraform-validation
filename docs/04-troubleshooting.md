# トラブルシューティング

## 2026-09-07: sandbox外にあるgcloudを直接起動できない

- 症状: 初回のCLI確認でWindowsのAccess denied
- 原因: Google Cloud SDKが作業領域外のユーザーディレクトリにインストールされていた
- 修正: 読み取り目的を明示して許可された実行に切り替え
- 結果: gcloud、認証、Project、Regionを匿名化したまま確認
- 区分: AI自律診断・修正。IAM変更なし

## 2026-09-07: Terraform `-chdir`へPowerShell変数が文字列展開されない

- 症状: `chdir $repo: The system cannot find the file specified`
- 原因: 外部コマンド引数`-chdir=$repo`が期待どおり展開されなかった
- 修正: `"-chdir=$repo"`を明示的に1引数として渡した
- 結果: root / bootstrapともinitとvalidate成功
- 区分: AI自律診断・修正。クラウド変更なし

## 2026-09-07: Application Default Credentials未設定

- 症状: ADC access tokenを取得できない
- 原因: gcloud CLIのユーザーログインとTerraformが利用するADCは別管理
- 対応: ADCファイルを新規保存せず、既存gcloudログインから発行した短時間tokenをplanプロセスだけへ渡した
- 結果: root / bootstrapのread-only plan成功。通常のローカル運用向けADCは未設定のまま

## 2026-09-07: bootstrap planの引数解析エラー

- 症状: `Too many command line arguments`が2回発生
- 原因: PowerShellからTerraformへ直接並べた引数の解釈がbootstrap実行時に崩れた
- 修正: 引数を配列化してsplatでTerraformへ渡した
- 結果: Terraform設定の評価まで到達
- 区分: AI自律診断・修正。クラウド変更なし

## 2026-09-07: custom role permissionsのset/list型不一致

- 症状: `Invalid value for "seqs" parameter: all arguments must be lists or tuples`
- 原因: Provider schema上set型の`permissions`を`concat`へ直接渡した
- 修正: `tolist()`で型だけを明示。Permission内容とscopeは変更なし
- 結果: bootstrap validateとplan成功
- 区分: AI自律診断・修正。IAM追加・クラウド変更なし

## 2026-09-07: CI planが既存18リソースを新規作成扱いにした

- 症状: WIF認証と`terraform init`は成功したが、PR planが`18 to add`を表示
- 原因: 実Bucket名を含まない`backend.tf`まで`.gitignore`対象となり、CI checkout後にGCS backend宣言が存在しなかった
- 修正: 空の`backend "gcs" {}`だけを含む`backend.tf`を追跡し、Bucket名とprefixは引き続きWorkflowから注入
- 安全判断: PR Workflowにapplyはなく、Cloud Resource変更は発生していない
- 区分: AI自律診断・修正。IAM拡張なし
