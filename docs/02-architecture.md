# GCPアーキテクチャ

## 構成図

```mermaid
flowchart TB
  client((Internet client))

  subgraph gcp[Google Cloud / Tokyo]
    ip[Global external IPv4]
    alb[Global External Application Load Balancer\nHTTP :80 / URL map / Backend service]

    subgraph vpc[Custom mode VPC]
      subgraph subnet[Regional private subnet]
        mig[Regional Managed Instance Group\n2 instances / 2 zones]
        vm1[Ubuntu + Nginx\nZone A / no external IP]
        vm2[Ubuntu + Nginx\nZone C / no external IP]
        nat[Cloud Router + Cloud NAT\nTCP 80/443 egress only]
      end
    end

    logs[Cloud Logging]
    monitor[Cloud Monitoring\nUptime check + alert policies]
    state[GCS Remote State\nversioning + backend locking]
    wif[Workload Identity Federation\nPR SA / Apply SA]
  end

  github[GitHub Actions]

  client -->|HTTP 80| ip --> alb
  alb -->|GFE / health-check CIDRs\nTCP 80 only| mig
  mig --- vm1
  mig --- vm2
  vm1 --> nat
  vm2 --> nat
  alb -. access and health logs .-> logs
  logs -. metrics .-> monitor
  github -->|OIDC| wif
  wif --> state
  wif -->|Terraform API calls| gcp
```

## GCP固有の判断

- SubnetはリージョンResourceで複数Zoneを包含するため、AZごとのSubnetは作らない。
- Regional MIGの`EVEN`配置で2台を2 Zoneへ分散し、Template、LB連携、自動復旧を一体管理する。
- Global External Application Load Balancerを採用し、GFE経由のHTTP、5xx metric、access log、health checkを利用する。
- Backend FirewallはGFE / Health Checkの公式送信元CIDRからTCP 80だけを許可する。
- Private VMのNginx導入に外部package repositoryが必要なためCloud NATを採用する。VM egressはTCP 80/443に限定する。
- Cloud Armor、Cloud CDN、GKE、Managed Service for Prometheusは今回の検証には過剰なため採用しない。
