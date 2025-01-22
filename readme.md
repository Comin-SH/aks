### Voraussetzung
- Terraform installiert
- Azure CLI installiert


### Vorbereitung
- Github Repo herunterladen
- Notwendige Anpassungen NUR in terraform.tfvars durchführen, Default Werte sieht man in variables.tf

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

`terraform apply -var `

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
