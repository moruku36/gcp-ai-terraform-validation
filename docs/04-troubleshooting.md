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
- 対応: Credential操作に該当するため、`gcloud auth application-default login`実行前に停止
- 状態: 未解決。plan/apply未実行
