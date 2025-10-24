terraform {
  required_version = ">=1.8.0"

  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "cidevttfstate18738"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

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
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
    # Es wurde ein alternativer kubectl Provider von Alek C gewählt, da dieser die Erstellung des Clusters und Kubernetes Ressourcen mit einem Apply ermöglicht.
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "kubectl" {
  host                   = module.aks_cluster.host
  client_certificate     = base64decode(module.aks_cluster.client_certificate)
  client_key             = base64decode(module.aks_cluster.client_key)
  cluster_ca_certificate = base64decode(module.aks_cluster.cluster_ca_certificate)
  load_config_file       = false
}

provider "helm" {
  kubernetes = {
    host                   = module.aks_cluster.host
    client_certificate     = base64decode(module.aks_cluster.client_certificate)
    client_key             = base64decode(module.aks_cluster.client_key)
    cluster_ca_certificate = base64decode(module.aks_cluster.cluster_ca_certificate)
  }
}
