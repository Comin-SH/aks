# Install ArgoCD via Helm and apply apps-of-apps + repository manifests

# Ensure we can fetch kubeconfig for the cluster created in this repo
data "azurerm_kubernetes_cluster" "aks" {
  name                = azurerm_kubernetes_cluster.k8s.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "8.6.4"
  namespace        = "argocd"
  create_namespace = true

  # Use the values file in the repo (argocd/values.yaml)
#   values = [
#     file("${path.root}/../argocd/values.yaml")
#   ]

  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

# # Apply the repository ConfigMap so ArgoCD knows the public GitHub repo
# resource "kubernetes_manifest" "argocd_repository" {
#   manifest = yamldecode(file("${path.root}/../argocd/repository.yaml"))
#   depends_on = [
#     helm_release.argocd
#   ]
# }

# Create the App of Apps Application in ArgoCD
resource "kubernetes_manifest" "argocd_apps_of_apps" {
  manifest = yamldecode(file("${path.root}/../argocd/apps-of-apps.yaml"))
#   depends_on = [
#     kubernetes_manifest.argocd_repository
#   ]
}