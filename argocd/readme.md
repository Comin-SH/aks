### Voraussetzung
- Azure CLI installiert
- kubectl installiert
- kubelogin installiert
- helm installiert
- argocd cli installieren

# Installation von Argo CD:
Prüfen, ob mit korrekten Cluster verbunden
```
k config get-contexts
``` 

# Repo hinzufügen und installieren im Namespace argocd (wird erstellt)
```
helm repo add argo https://argoproj.github.io/argo-helm

helm install argocd argo/argo-cd -n argocd --create-namespace  # --values=values.yaml
```


# Installation prüfen
```
kubectl get pods -n argocd
kubectl port-forward svc/argocd-server -n argocd 8080:https
```

# Initiales Passwort anzeigen lassen
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

# GitHub Repo, welches Apps of Apps enthält hinzufügen (nur notwendig für private Repos)
```
kubectl apply -f repository.yaml
```



```
argo cd login

# argocd repo add ???
```

ArgoCD initial über Helm installieren, wenn die Verwaltung von Argo CD auch über die Apps of Apps Pattern erfolgt, kann dies mittels folgendem Befehl aus der Helm Übersicht entfernt werden


```
kubectl delete secret -n argocd -l owner=helm,name=argocd
```
