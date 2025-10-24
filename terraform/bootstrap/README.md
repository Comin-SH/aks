# Bootstrap Module

Dieses Modul enthält alle Ressourcen, die nach der Infrastruktur-Bereitstellung für den Cluster-Bootstrap benötigt werden.

## Enthaltene Komponenten

### ArgoCD Installation (`argocd.tf`)
- Installiert ArgoCD via Helm Chart (Version 9.0.2)
- Deployed die App-of-Apps Applikation für GitOps

### Grafana Secrets Setup (`grafana-secrets.tf`)
- Generiert SecretProviderClass für Azure Key Vault Integration
- Erstellt YAML-Datei für Kubernetes Secret mit Grafana Admin-Credentials
- Verwendet Workload Identity für sichere Key Vault Zugriffe

**Wichtig:** Die SecretProviderClass wird **nicht direkt von Terraform** im Cluster deployed, 
sondern als YAML-Datei im Git-Repository abgelegt. ArgoCD synchronisiert die Datei, 
sobald der `monitoring` Namespace durch die Monitoring-Application erstellt wurde.

## Verwendung

Dieses Modul wird automatisch vom Root-Modul (`main.tf`) aufgerufen:

```hcl
module "bootstrap" {
  source = "./bootstrap"

  aks_cluster_id                 = module.aks_cluster.cluster_id
  monitoring_identity_client_id  = module.key_vault.monitoring_identity_client_id
  key_vault_name                 = module.key_vault.key_vault_name
  key_vault_id                   = module.key_vault.key_vault_id
  tenant_id                      = data.azurerm_client_config.current.tenant_id
}
```

## Abhängigkeiten

- AKS Cluster muss existieren
- Key Vault muss provisioniert sein
- Workload Identity muss konfiguriert sein

## Deployment-Ablauf

1. **Terraform apply** erstellt:
   - ArgoCD via Helm im `argocd` Namespace
   - App-of-Apps Application
   - SecretProviderClass YAML-Datei (im Git-Repo)

2. **ArgoCD** synchronisiert automatisch:
   - Erstellt `monitoring` Namespace
   - Deployed Monitoring-Stack (Prometheus, Grafana, Loki)
   - Deployed SecretProviderClass (aus der generierten YAML-Datei)

3. **Grafana** verwendet:
   - SecretProviderClass zum Laden der Credentials aus Key Vault
   - Workload Identity für authentifizierten Zugriff

**Hinweis:** Die SecretProviderClass existiert erst im Cluster, nachdem ArgoCD 
die Monitoring-Application synchronisiert hat. Dies ist beabsichtigt und Teil 
des GitOps-Workflows.

## Outputs

- `argocd_namespace`: Namespace für ArgoCD
- `argocd_release_name`: Helm Release Name
- `argocd_version`: Installierte ArgoCD Version
- `grafana_secret_provider_class_file`: Pfad zur generierten YAML-Datei
