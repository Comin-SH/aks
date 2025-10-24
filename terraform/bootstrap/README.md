# Bootstrap Module

Dieses Modul enthält alle Ressourcen, die nach der Infrastruktur-Bereitstellung für den Cluster-Bootstrap benötigt werden.

## Enthaltene Komponenten

### ArgoCD Installation (`argocd.tf`)
- Installiert ArgoCD via Helm Chart (Version 9.0.2)
- Deployed die App-of-Apps Applikation für GitOps

### Grafana Secrets Setup (`grafana-secrets.tf`)
- Generiert SecretProviderClass für Azure Key Vault Integration
- Erstellt Kubernetes Secret für Grafana Admin-Credentials
- Verwendet Workload Identity für sichere Key Vault Zugriffe

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

## Outputs

- `argocd_namespace`: Namespace für ArgoCD
- `argocd_release_name`: Helm Release Name
- `argocd_version`: Installierte ArgoCD Version
- `grafana_secret_provider_class_file`: Pfad zur generierten YAML-Datei
