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


resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.2"
  namespace  = "argocd"

  depends_on = [helm_release.argocd]

  values = [yamlencode({
    applications = {
      "app-of-apps" = {
        # name ist optional, der Key ("app-of-apps") wird als metadata.name verwendet
        namespace = "argocd"
        project   = "default"
        source = {
          repoURL        = "https://github.com/Comin-SH/aks.git"
          targetRevision = "HEAD"
          path           = "argocd/applications"
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = "argocd"
        }
        syncPolicy = {
          automated   = { prune = true, selfHeal = true }
          syncOptions = ["CreateNamespace=true"]
        }
      }
    }
  })]
}
