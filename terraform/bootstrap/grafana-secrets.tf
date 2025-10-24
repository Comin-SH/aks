# Lokale YAML-Datei generieren für ArgoCD
# Die Datei wird von ArgoCD deployed, wenn der monitoring Namespace existiert
resource "local_file" "grafana_secret_provider_class" {
  content = <<-YAML
    apiVersion: secrets-store.csi.x-k8s.io/v1
    kind: SecretProviderClass
    metadata:
      name: grafana-admin-credentials
      namespace: monitoring
    spec:
      provider: azure
      parameters:
        usePodIdentity: "false"
        clientID: ${var.monitoring_identity_client_id}
        keyvaultName: ${var.key_vault_name}
        objects: |
          array:
            - |
              objectName: grafana-admin-user
              objectType: secret
            - |
              objectName: grafana-admin-password
              objectType: secret
        tenantId: ${var.tenant_id}
      secretObjects:
      - data:
        - key: admin-user
          objectName: grafana-admin-user
        - key: admin-password
          objectName: grafana-admin-password
        secretName: grafana-admin-credentials
        type: Opaque
  YAML

  filename = "${path.root}/../argocd/applications/monitoring/kube-prometheus-stack/grafana/admin-credentials/secret-provider-class.yaml"
}

# HINWEIS: Die SecretProviderClass wird NICHT direkt von Terraform deployed,
# sondern über ArgoCD, da der monitoring Namespace erst von ArgoCD erstellt wird.
# Die YAML-Datei wird im Git-Repo abgelegt und von ArgoCD synchronisiert.
