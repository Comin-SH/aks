# Install ArgoCD via Helm and apply apps-of-apps + repository manifests

# Ensure we can fetch kubeconfig for the cluster created in this repo
# data "azurerm_kubernetes_cluster" "aks" {
#   name                = azurerm_kubernetes_cluster.k8s.name
#   resource_group_name = azurerm_resource_group.rg.name
# }

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.0.2"
  namespace        = "argocd"
  create_namespace = true
  #upgrade_install  = true

  # Use the values file in the repo (argocd/values.yaml)
  #   values = [
  #     file("${path.root}/../argocd/values.yaml")
  #   ]

  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]

  # depends_on = [time_sleep.wait_for_api]
}

# # Apply the repository ConfigMap so ArgoCD knows the public GitHub repo
# resource "kubernetes_manifest" "argocd_repository" {
#   manifest = yamldecode(file("${path.root}/../argocd/repository.yaml"))
#   depends_on = [
#     helm_release.argocd
#   ]
# }

# Create the App of Apps Application in ArgoCD

# locals {
# resource_list = yamldecode(file("${path.module}/../argocd/apps-of-apps.yaml"))
# }


# resource "kubectl_manifest" "test" {
#     count     = length(local.resource_list)
#     yaml_body = yamlencode(local.resource_list[count.index]) 
# }

resource "kubectl_manifest" "argocd_apps_of_apps" {
  yaml_body  = file("${path.root}/../argocd/apps-of-apps.yaml")
  depends_on = [helm_release.argocd]
}

# resource "kubectl_manifest" "argocd_apps_of_apps" {
#   yaml_body = yamldecode(file("${path.root}/../argocd/apps-of-apps.yaml"))
#   depends_on = [
#     helm_release.argocd
#   ]
# }