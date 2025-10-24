# Install ArgoCD via Helm and apply apps-of-apps manifest

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "9.0.2"
  namespace        = "argocd"
  create_namespace = true

  depends_on = [
    var.aks_cluster_id
  ]
}

# Create the App of Apps Application in ArgoCD
resource "kubectl_manifest" "argocd_apps_of_apps" {
  yaml_body  = file("${path.root}/../argocd/bootstrap/apps-of-apps.yaml")
  depends_on = [helm_release.argocd]
}
