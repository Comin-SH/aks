### Voraussetzung
- Terraform installiert
- Azure CLI installiert
- kubectl installiert
- kubelogin installiert

- letzen beiden Punkten können mit folgenden Code installiert werden
`az aks install-cli`

### Vorbereitung
- Github Repo herunterladen
- Notwendige Anpassungen NUR in terraform.tfvars durchführen, Default Werte sieht man in variables.tf
- admin_group_object_ids und rbac_reader_group_object_ids können mit der Object ID von Entra ID Gruppen befüllt werden, so dass Mitglieder dieser Gruppe entsprechend lesenden oder administrativen Zugriff auf das Kubernetes Cluster bekommen


### Schritte
1. Als erstes Mittels "az login" anmelden und korrekte Subscription auswählen. Mit dem zweiten Befehl kann geprüft werden, ob korrekte Subscription ausgewählt ist.

<code>
az login

az account show
</code>

2. Führen Sie zum Initialisieren der Terraform-Bereitstellung terraform init aus. Mit diesem Befehl wird der Azure-Anbieter heruntergeladen, der zum Verwalten Ihrer Azure-Ressourcen erforderlich ist.

`terraform init -upgrade` 

3. Anzeigen was Terraform tun wird.

`terraform plan`

4. Ausführen der Bereitstellung

`terraform apply`

5. Kubeconfig erzeugen, wird automatisch mit bestehender config zusammengeführt

`az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)`

6. Azure Kubernetes Ressource im Azure Portal öffnen (optional)

`az aks browse --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name)`

7. Löschen der Bereitstellung

`terraform destroy`

8. Löschen von Cluster aus kubeconfig

`kubectl config delete-cluster <clustername>`



Quellen:
https://learn.microsoft.com/de-de/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli --> hier wurden alle random (Pet) Variablen durch statische Variablen ersetzt.

https://developer.hashicorp.com/terraform/tutorials/kubernetes/aks

Details zu Azure RBAC: https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac?tabs=azure-cli



## Installation von Argo CD
Es wird zu diesem Stand darauf verzichtet Argo CD mittels Terraform bereitzustellen, stattdessen wird dieser Schritt einmalig manuell für das Cluster ausgeführt

Begründung:
- bei der Bereitstellung mittels Terraform müsste auch Updates für Argo CD mittels Terraform durchgeführt werden, dies wird als unpraktisch bewertet
- eine Aktualisierung von ArgoCD nachträglich über andere Mittel, würde zu einem Versionsunterschied zwischen Terraform und Realität führen
- bei einer manuellen Installation von ArgoCD kann sich dies nach der Bereitstellung selbst aktualisieren und verwalten

**Weitere Schritte im Ordner argocd**



