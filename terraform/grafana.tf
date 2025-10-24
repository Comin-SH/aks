# Lokale YAML-Datei generieren
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
        clientID: ${azurerm_user_assigned_identity.monitoring.client_id}
        keyvaultName: ${azurerm_key_vault.kv.name}
        objects: |
          array:
            - |
              objectName: grafana-admin-user
              objectType: secret
            - |
              objectName: grafana-admin-password
              objectType: secret
        tenantId: ${data.azurerm_client_config.current.tenant_id}
      secretObjects:
      - data:
        - key: admin-user
          objectName: grafana-admin-user
        - key: admin-password
          objectName: grafana-admin-password
        secretName: grafana-admin-credentials
        type: Opaque
  YAML

  filename = "${path.root}/../argocd/apps/monitoring/kube-prometheus-stack/grafana/admin-credentials/secret-provider-class.yaml"
}

# SecretProviderClass im Cluster erstellen
resource "kubectl_manifest" "grafana_secret_provider_class" {
  yaml_body = local_file.grafana_secret_provider_class.content

  depends_on = [
    helm_release.argocd,
    azurerm_user_assigned_identity.monitoring,
    azurerm_federated_identity_credential.grafana
  ]
}