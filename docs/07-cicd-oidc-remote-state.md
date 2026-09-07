# CI/CD・Workload Identity Federation・Remote State

## 認証設計

```text
GitHub OIDC token
  -> Workload Identity Pool Provider
  -> exact GitHub subject
  -> PR用またはApply用Service Account
  -> GCP API / GCS State
```

- Issuerは`https://token.actions.githubusercontent.com`のみ
- Provider条件は`repository_owner`と`repository`を固定
- PR subjectは`repo:moruku36/gcp-ai-terraform-validation:pull_request`
- Apply subjectは`repo:moruku36/gcp-ai-terraform-validation:environment:terraform-production`
- fork PRは同じbase repository subjectになり得るため、Workflowでも`head.repo.full_name == github.repository`を必須化
- Service Account Key、Client Secret、長期Credentialは作成しない
- PR SAはread-only custom roleとState Object Viewer
- Apply SAはrootが管理するResource familyのCRUD custom roleとState Object Admin

## Remote State

- GCS専用Bucket
- Uniform Bucket-Level Access
- Public Access Prevention `enforced`
- Object Versioning
- Google管理サーバー側暗号化
- prefix: `terraform/root`
- Terraform GCS Backend標準のState locking
- PR planだけ`-lock=false`とし、State書込み権限を付与しない

移行時はLocal Stateをignored directoryへ保存し、移行元とbackupのSHA-256一致後に`terraform init -migrate-state`を実行する。移行前後のState resource数、lineage、serial、plan結果を秘密値を出さず確認する。

## 移行結果

- Local Stateをignored directoryへコピーし、移行元とbackupのSHA-256一致を確認
- `terraform init -migrate-state -force-copy`で`terraform/root` prefixへ移行
- GCS上のState object、lineage一致、State内17リソースを確認
- 移行に伴いState serialは1増加したが、既存Resourceの差分はなし
- 通常のlockingを有効にしたplanが成功し、終了後に孤立lockがないことを確認
- 移行後のroot planはNo changes

## GitHub設定

Repository / Environment Secrets:

- `GCP_PROJECT_ID`
- `GCP_WIF_PROVIDER`
- `GCP_PR_SERVICE_ACCOUNT`
- `GCP_APPLY_SERVICE_ACCOUNT`
- `GCP_TF_STATE_BUCKET`

Repository Variable:

- `GCP_ENVIRONMENT_ACTIVE`

`terraform-production`はmain限定とし、cleanup前に`GCP_ENVIRONMENT_ACTIVE=false`へ変更してcloud jobのskipを確認する。

## PR OIDC subject検証

初回のRemote State接続では、Service Account access token取得時に`iam.serviceAccounts.getAccessToken`が拒否された。JWT本体を出力しない一時stepで`sub`と`aud`だけを確認した結果、`aud`はWIF Providerと一致した一方、`sub`にはGitHub owner/repositoryの安定numeric IDが含まれていた。

TerraformのPR subjectを次の匿名化形式へ変更した。

```text
repo:<OWNER>@<OWNER_ID>/<REPOSITORY>@<REPOSITORY_ID>:pull_request
```

- exact subjectを維持し、wildcardや`principalSet`へ緩和しない
- Providerのrepository name/owner condition、audience、Apply subjectは変更しない
- `roles/iam.workloadIdentityUser`以外の権限を追加しない
- IAM memberは`create_before_destroy`で新binding作成後に旧bindingを削除
- bootstrap apply後のplanはNo changes
- 修正後のPR WorkflowでWIF認証、GCS backend初期化、root plan No changesを確認
- claim確認用の一時デバッグstepは認証成功後に削除

Apply Environmentのsubjectは実token確認後に別途判断する。
