# Outputs des Bootstrap-Moduls

output "argocd_namespace" {
  description = "Namespace in dem ArgoCD installiert wurde"
  value       = helm_release.argocd.namespace
}

output "argocd_release_name" {
  description = "Name des ArgoCD Helm Release"
  value       = helm_release.argocd.name
}

output "argocd_version" {
  description = "Version von ArgoCD"
  value       = helm_release.argocd.version
}

output "grafana_secret_provider_class_file" {
  description = "Pfad zur generierten SecretProviderClass YAML-Datei"
  value       = local_file.grafana_secret_provider_class.filename
}
