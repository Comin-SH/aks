# ArgoCD - GitOps für AKS# ArgoCD - GitOps für AKS### Voraussetzung



Dieses Verzeichnis enthält die ArgoCD-Konfiguration für das GitOps-basierte Deployment von Kubernetes-Applikationen.- Azure CLI installiert



## 📁 StrukturDieses Verzeichnis enthält die ArgoCD-Konfiguration für das GitOps-basierte Deployment von Kubernetes-Applikationen.- kubectl installiert



```- kubelogin installiert

argocd/

├── README.md                           # Diese Datei## 📁 Struktur- helm installiert

├── bootstrap/                          # Bootstrap-Ressourcen

│   ├── apps-of-apps.yaml              # App of Apps Pattern- argocd cli installieren

│   └── repository.yaml                # Git Repository Secret (optional)

├── applications/                       # Application Definitions```

│   ├── argocd-application.yaml        # ArgoCD selbst

│   ├── monitoring-application.yaml    # Monitoring Stackargocd/# Installation von Argo CD:

│   ├── nextcloud-application.yaml     # Nextcloud

│   ├── argocd/                        # ArgoCD Values├── README.md                           # Diese DateiPrüfen, ob mit korrekten Cluster verbunden

│   ├── monitoring/                    # Monitoring Config & Values

│   └── nextcloud/                     # Nextcloud Config├── bootstrap/                          # Bootstrap-Ressourcen```

└── values/                            # Shared Values

    └── common.yaml                    # Gemeinsame Konfiguration│   ├── apps-of-apps.yaml              # App of Apps Patternk config get-contexts

```

│   └── repository.yaml                # Git Repository Secret (optional)``` 

## Voraussetzungen

├── applications/                       # Application Definitions

- Azure CLI installiert

- kubectl installiert│   ├── argocd-application.yaml        # ArgoCD selbst# Repo hinzufügen und installieren im Namespace argocd (wird erstellt)

- kubelogin installiert

- helm installiert│   ├── monitoring-application.yaml    # Monitoring Stack```

- argocd CLI installiert (optional)

│   ├── nextcloud-application.yaml     # Nextcloudhelm repo add argo https://argoproj.github.io/argo-helm

## 🚀 Installation

│   ├── argocd/                        # ArgoCD Values

### 1. Cluster-Kontext prüfen

│   ├── monitoring/                    # Monitoring Config & Valueshelm install argocd argo/argo-cd -n argocd --create-namespace  # --values=values.yaml

```bash

kubectl config get-contexts│   └── nextcloud/                     # Nextcloud Config```

kubectl config current-context

```└── values/                            # Shared Values



### 2. ArgoCD installieren    └── common.yaml                    # Gemeinsame Konfiguration



```bash```# Installation prüfen

# Helm Repository hinzufügen

helm repo add argo https://argoproj.github.io/argo-helm```

helm repo update

## Voraussetzungenkubectl get pods -n argocd

# ArgoCD im Namespace argocd installieren

helm install argocd argo/argo-cd -n argocd --create-namespacekubectl port-forward svc/argocd-server -n argocd 8080:https

```

- Azure CLI installiert```

### 3. Installation prüfen

- kubectl installiert

```bash

# Pods prüfen- kubelogin installiert# Initiales Passwort anzeigen lassen

kubectl get pods -n argocd

- helm installiert```

# Warten bis alle Pods ready sind

kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s- argocd CLI installiert (optional)kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

```

```

### 4. ArgoCD UI Zugriff

## 🚀 Installation

```bash

# Port-Forwarding zum ArgoCD Server# GitHub Repo, welches Apps of Apps enthält hinzufügen (nur notwendig für private Repos)

kubectl port-forward svc/argocd-server -n argocd 8080:443

```### 1. Cluster-Kontext prüfen```



Öffne https://localhost:8080 im Browser.kubectl apply -f repository.yaml



### 5. Initiales Admin-Passwort```bash```



```bashkubectl config get-contexts

# Passwort anzeigen

kubectl -n argocd get secret argocd-initial-admin-secret \kubectl config current-context

  -o jsonpath="{.data.password}" | base64 -d; echo

``````



Login: `admin` / `<angezeigtes-passwort>````



### 6. Repository konfigurieren (nur für private Repos)### 2. ArgoCD installierenargo cd login



```bash

# Für private GitHub Repositories

kubectl apply -f bootstrap/repository.yaml```bash# argocd repo add ???

```

# Helm Repository hinzufügen```

Für öffentliche Repos ist dieser Schritt nicht notwendig.

helm repo add argo https://argoproj.github.io/argo-helm

### 7. App of Apps deployen

helm repo updateArgoCD initial über Helm installieren, wenn die Verwaltung von Argo CD auch über die Apps of Apps Pattern erfolgt, kann dies mittels folgendem Befehl aus der Helm Übersicht entfernt werden

```bash

# Apps of Apps Pattern aktivieren

kubectl apply -f bootstrap/apps-of-apps.yaml

```# ArgoCD im Namespace argocd installieren



Dies deployed automatisch alle Applikationen aus dem `applications/` Verzeichnis:helm install argocd argo/argo-cd -n argocd --create-namespace```

- ArgoCD (Self-Management)

- Monitoring Stack (Prometheus, Grafana, Loki)```kubectl delete secret -n argocd -l owner=helm,name=argocd

- Nextcloud

```

### 8. Deployment-Status prüfen

### 3. Installation prüfen

```bash

# Alle Applications anzeigen```bash

kubectl get applications -n argocd# Pods prüfen

kubectl get pods -n argocd

# Oder mit ArgoCD CLI

argocd app list# Warten bis alle Pods ready sind

kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Details einer Application```

argocd app get monitoring

```### 4. ArgoCD UI Zugriff



## 🔧 ArgoCD CLI (Optional)```bash

# Port-Forwarding zum ArgoCD Server

### Installationkubectl port-forward svc/argocd-server -n argocd 8080:443

```

```bash

# macOSÖffne https://localhost:8080 im Browser.

brew install argocd

### 5. Initiales Admin-Passwort

# Oder direkt download

curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-darwin-arm64```bash

chmod +x argocd# Passwort anzeigen

sudo mv argocd /usr/local/bin/kubectl -n argocd get secret argocd-initial-admin-secret \

```  -o jsonpath="{.data.password}" | base64 -d; echo

```

### Login

Login: `admin` / `<angezeigtes-passwort>`

```bash

# Mit Port-Forward### 6. Repository konfigurieren (nur für private Repos)

argocd login localhost:8080 --insecure

```bash

# Username: admin# Für private GitHub Repositories

# Password: <initiales Passwort von oben>kubectl apply -f bootstrap/repository.yaml

``````



## 📦 Deployed ApplicationsFür öffentliche Repos ist dieser Schritt nicht notwendig.



### Monitoring Stack### 7. App of Apps deployen

- **Kube-Prometheus-Stack**: Prometheus, Grafana, Alertmanager

- **Loki**: Log-Aggregation mit Azure Blob Storage```bash

- **X.509 Certificate Exporter**: Zertifikats-Monitoring# Apps of Apps Pattern aktivieren

kubectl apply -f bootstrap/apps-of-apps.yaml

### Nextcloud```

- Collaborative Cloud Storage Platform

Dies deployed automatisch alle Applikationen aus dem `applications/` Verzeichnis:

### ArgoCD- ArgoCD (Self-Management)

- Self-Management via GitOps- Monitoring Stack (Prometheus, Grafana, Loki)

- Nextcloud

## 🔄 Self-Management

### 8. Deployment-Status prüfen

Nach erfolgreicher Installation kann ArgoCD sich selbst über Git verwalten.

```bash

Optional: Helm-Verwaltung entfernen (um Konflikte zu vermeiden):# Alle Applications anzeigen

kubectl get applications -n argocd

```bash

# Entfernt ArgoCD aus Helm-Tracking (GitOps übernimmt)# Oder mit ArgoCD CLI

kubectl delete secret -n argocd -l owner=helm,name=argocdargocd app list

```

# Details einer Application

⚠️ **Vorsicht**: Nach diesem Schritt kann ArgoCD NICHT mehr über Helm verwaltet werden!argocd app get monitoring

```

## 🎯 GitOps Workflow

## 🔧 ArgoCD CLI (Optional)

### Neue Application hinzufügen

### Installation

1. Erstelle YAML in `applications/`:

   ```yaml```bash

   apiVersion: argoproj.io/v1alpha1# macOS

   kind: Applicationbrew install argocd

   metadata:

     name: my-app# Oder direkt download

     namespace: argocdcurl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-darwin-arm64

   spec:chmod +x argocd

     project: defaultsudo mv argocd /usr/local/bin/

     source:```

       repoURL: https://github.com/Comin-SH/aks.git

       targetRevision: HEAD### Login

       path: argocd/applications/my-app

     destination:```bash

       server: https://kubernetes.default.svc# Mit Port-Forward

       namespace: my-appargocd login localhost:8080 --insecure

     syncPolicy:

       automated:# Username: admin

         prune: true# Password: <initiales Passwort von oben>

         selfHeal: true```

   ```

## 📦 Deployed Applications

2. Commit & Push zu Git

3. ArgoCD erkennt Änderung automatisch und deployed### Monitoring Stack

- **Kube-Prometheus-Stack**: Prometheus, Grafana, Alertmanager

### Application löschen- **Loki**: Log-Aggregation mit Azure Blob Storage

- **X.509 Certificate Exporter**: Zertifikats-Monitoring

```bash

# Via kubectl### Nextcloud

kubectl delete application <app-name> -n argocd- Collaborative Cloud Storage Platform



# Via ArgoCD CLI### ArgoCD

argocd app delete <app-name>- Self-Management via GitOps

```

## 🔄 Self-Management

## 🔐 Secrets Management

Nach erfolgreicher Installation kann ArgoCD sich selbst über Git verwalten.

Grafana Admin-Credentials werden über Azure Key Vault CSI Driver bereitgestellt:

- Secret Provider Class: `applications/monitoring/kube-prometheus-stack/grafana/admin-credentials/secret-provider-class.yaml`Optional: Helm-Verwaltung entfernen (um Konflikte zu vermeiden):

- Terraform erstellt die Secrets im Key Vault

```bash

## 📊 Monitoring# Entfernt ArgoCD aus Helm-Tracking (GitOps übernimmt)

kubectl delete secret -n argocd -l owner=helm,name=argocd

### Grafana Zugriff```



```bash⚠️ **Vorsicht**: Nach diesem Schritt kann ArgoCD NICHT mehr über Helm verwaltet werden!

# Port-Forward zu Grafana

kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80## 🎯 GitOps Workflow

```

### Neue Application hinzufügen

Öffne http://localhost:3000

- Username: `admin` (aus Key Vault)1. Erstelle YAML in `applications/`:

- Password: siehe Key Vault Secret `grafana-admin-password`   ```yaml

   apiVersion: argoproj.io/v1alpha1

### Prometheus Zugriff   kind: Application

   metadata:

```bash     name: my-app

kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090     namespace: argocd

```   spec:

     project: default

Öffne http://localhost:9090     source:

       repoURL: https://github.com/Comin-SH/aks.git

## 🐛 Troubleshooting       targetRevision: HEAD

       path: argocd/applications/my-app

### Application synchronisiert nicht     destination:

       server: https://kubernetes.default.svc

```bash       namespace: my-app

# Status prüfen     syncPolicy:

argocd app get <app-name>       automated:

         prune: true

# Manuell synchronisieren         selfHeal: true

argocd app sync <app-name>   ```



# Mit Force (bei Konflikten)2. Commit & Push zu Git

argocd app sync <app-name> --force3. ArgoCD erkennt Änderung automatisch und deployed

```

### Application löschen

### Out-of-Sync angezeigt

```bash

```bash# Via kubectl

# Diff anzeigenkubectl delete application <app-name> -n argocd

argocd app diff <app-name>

# Via ArgoCD CLI

# Refresh (Git-Repo neu scannen)argocd app delete <app-name>

argocd app get <app-name> --refresh```

```

## 🔐 Secrets Management

### Pods starten nicht

Grafana Admin-Credentials werden über Azure Key Vault CSI Driver bereitgestellt:

```bash- Secret Provider Class: `applications/monitoring/kube-prometheus-stack/grafana/admin-credentials/secret-provider-class.yaml`

# Events prüfen- Terraform erstellt die Secrets im Key Vault

kubectl get events -n <namespace> --sort-by='.lastTimestamp'

## 📊 Monitoring

# Logs anzeigen

kubectl logs -n <namespace> <pod-name>### Grafana Zugriff



# Describe Pod```bash

kubectl describe pod -n <namespace> <pod-name># Port-Forward zu Grafana

```kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

```

## 📚 Weitere Dokumentation

Öffne http://localhost:3000

- [Monitoring Setup](./applications/monitoring/README.md)- Username: `admin` (aus Key Vault)

- [Grafana Configuration](./applications/monitoring/kube-prometheus-stack/README.md)- Password: siehe Key Vault Secret `grafana-admin-password`

- [Loki Setup](./applications/monitoring/loki/README.md)

### Prometheus Zugriff

## 🔗 Referenzen

```bash

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

- [App of Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)```

- [GitOps Best Practices](https://www.gitops.tech/)

Öffne http://localhost:9090

## 🐛 Troubleshooting

### Application synchronisiert nicht

```bash
# Status prüfen
argocd app get <app-name>

# Manuell synchronisieren
argocd app sync <app-name>

# Mit Force (bei Konflikten)
argocd app sync <app-name> --force
```

### Out-of-Sync angezeigt

```bash
# Diff anzeigen
argocd app diff <app-name>

# Refresh (Git-Repo neu scannen)
argocd app get <app-name> --refresh
```

### Pods starten nicht

```bash
# Events prüfen
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Logs anzeigen
kubectl logs -n <namespace> <pod-name>

# Describe Pod
kubectl describe pod -n <namespace> <pod-name>
```

## 📚 Weitere Dokumentation

- [Monitoring Setup](./applications/monitoring/README.md)
- [Grafana Configuration](./applications/monitoring/kube-prometheus-stack/README.md)
- [Loki Setup](./applications/monitoring/loki/README.md)

## 🔗 Referenzen

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [App of Apps Pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/)
- [GitOps Best Practices](https://www.gitops.tech/)
