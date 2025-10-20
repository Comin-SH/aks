terraform {
  required_version = ">=1.8.0"


# Warum ~> x.0? Du bekommst automatisch Patches & Minor-Fixes, aber keine Major-Sprünge (Breaking Changes).
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
       version = "~> 4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    # Es wurde ein alternativer kubectl Provider von Gavin Bunney gewählt, da dieser die Erstellung des Clusters und Kubernetes Ressourcen mit einem Apply ermöglicht.
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}


provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].cluster_ca_certificate)
  # load_config_file       = false
}

provider "helm" {
  kubernetes = {
    host                   = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].cluster_ca_certificate)
  }
}
