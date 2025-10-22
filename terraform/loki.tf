# Federated Credential: entspricht 2.2. Service Account f�r Loki mit Workload Identity verkn�pfen, entspricht:
# $AKS_OIDC_ISSUER=$(az aks show --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME --query "oidcIssuerProfile.issuerUrl" -o tsv)
# $FEDERATED_CREDENTIAL_NAME='monitoring-loki'
# $FEDERATED_CREDENTIAL_SUBJECT='system:serviceaccount:monitoring:loki'
# az identity federated-credential create --name $FEDERATED_CREDENTIAL_NAME --identity-name $WORKLOAD_IDENTITY_NAME --resource-group $RESOURCE_GROUP --issuer $AKS_OIDC_ISSUER --subject $FEDERATED_CREDENTIAL_SUBJECT
resource "azurerm_federated_identity_credential" "loki" {
  resource_group_name = var.resource_group_name
  name      = "monitoring-loki"
  parent_id = azurerm_user_assigned_identity.workload_identity.id
  issuer   = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject  = "system:serviceaccount:monitoring:loki"
  audience = ["api://AzureADTokenExchange"]
}