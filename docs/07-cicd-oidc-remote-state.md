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

## GitHub設定予定

Repository / Environment Secrets候補:

- `GCP_PROJECT_ID`
- `GCP_WIF_PROVIDER`
- `GCP_PR_SERVICE_ACCOUNT`
- `GCP_APPLY_SERVICE_ACCOUNT`
- `GCP_TF_STATE_BUCKET`

Repository Variable:

- `GCP_ENVIRONMENT_ACTIVE`

`terraform-production`はmain限定とし、cleanup前に`GCP_ENVIRONMENT_ACTIVE=false`へ変更してcloud jobのskipを確認する。
