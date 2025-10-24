# TODO - AKS Terraform Infrastruktur

Dieses Dokument listet offene Aufgaben und Verbesserungen für die AKS Terraform-Infrastruktur auf.

---

## 🔴 KRITISCH (Sollte zeitnah umgesetzt werden)

### 1. Tags-System implementieren
**Status:** ⏳ Offen  
**Priorität:** Hoch  
**Beschreibung:** Tags fehlen komplett in der aktuellen Konfiguration. Ohne Tags ist Resource-Management und Kostenzuordnung schwierig.

**Aufgaben:**
- [ ] `terraform/locals.tf` erstellen mit Tag-Definitionen
- [ ] Variable `environment` in `terraform/variables.tf` hinzufügen (mit Validation)
- [ ] Tags zu `azurerm_resource_group.rg` in `main.tf` hinzufügen
- [ ] Tags an alle Module übergeben (aks_cluster, key_vault, blob_storage)
- [ ] Optional: Weitere Tag-Variablen hinzufügen (project_name, owner_email, cost_center)

**Beispiel:**
```hcl
# locals.tf
locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = "AKS-Platform"
  }
}
```

---

### 2. Backend-Konfiguration auslagern
**Status:** ⏳ Offen  
**Priorität:** Hoch  
**Beschreibung:** Storage Account Name ist aktuell hardcoded in `providers.tf`, was die Flexibilität für verschiedene Umgebungen (dev/staging/prod) einschränkt.

**Aufgaben:**
- [ ] `terraform/backend.hcl.example` erstellen als Vorlage
- [ ] `providers.tf` anpassen: `backend "azurerm" {}` (leere Konfiguration)
- [ ] `.gitignore` erweitern um `backend.hcl` und `backend-*.hcl`
- [ ] README.md aktualisieren mit Backend-Initialisierung: `terraform init -backend-config=backend.hcl`

**Beispiel backend.hcl.example:**
```hcl
resource_group_name  = "tfstate"
storage_account_name = "your-storage-account-name"
container_name       = "tfstate"
key                  = "terraform.tfstate"
```

---

### 3. Lifecycle-Regeln für kritische Ressourcen
**Status:** ⏳ Offen  
**Priorität:** Hoch  
**Beschreibung:** Kritische Ressourcen sollten vor versehentlichem Löschen geschützt werden.

**Aufgaben:**
- [ ] Lifecycle-Regel in `modules/key-vault/main.tf` hinzufügen (prevent_destroy)
- [ ] Lifecycle-Regel in `modules/aks-cluster/main.tf` hinzufügen
- [ ] Lifecycle-Regel in `modules/blob-storage/main.tf` hinzufügen (Loki Daten!)
- [ ] Optional: ignore_changes für auto-generierte Tags

**Beispiel:**
```hcl
lifecycle {
  prevent_destroy = true
  ignore_changes  = [tags["CreatedDate"]]
}
```

---

## 🟡 WICHTIG (Empfohlen für bessere Wartbarkeit)

### 4. ArgoCD Version parametrisieren
**Status:** ⏳ Offen  
**Priorität:** Mittel  
**Beschreibung:** ArgoCD Version ist hardcoded in `bootstrap/argocd.tf`, erschwert Updates.

**Aufgaben:**
- [ ] Variable `argocd_version` in `bootstrap/variables.tf` hinzufügen
- [ ] `bootstrap/argocd.tf` anpassen: `version = var.argocd_version`
- [ ] Variable vom Haupt-Modul übergeben oder Default verwenden
- [ ] Dokumentation in `bootstrap/README.md` aktualisieren

---

### 5. Provider-Versionen in separate versions.tf auslagern
**Status:** ⏳ Offen  
**Priorität:** Mittel  
**Beschreibung:** Best Practice für bessere Übersicht und Wartbarkeit.

**Aufgaben:**
- [ ] `terraform/versions.tf` erstellen
- [ ] `required_version` und `required_providers` von `providers.tf` verschieben
- [ ] `terraform {}` Block mit Backend in `providers.tf` belassen (ohne required_providers)
- [ ] Dokumentation aktualisieren

---

### 6. Aufräumen und Organisation
**Status:** ⏳ Offen  
**Priorität:** Niedrig-Mittel  

**Aufgaben:**
- [ ] `terraform/.backup/` Verzeichnis entfernen (alte Backup-Dateien)
- [ ] `terraform/main.tf.modules-example` löschen (nicht mehr benötigt)
- [ ] Überprüfen ob `.terraform.lock.hcl` committed werden soll (Empfehlung: Ja)

---

## 🟢 OPTIONAL (Nice-to-have für langfristige Verbesserungen)

### 7. Pre-commit Hooks für Code-Qualität
**Status:** ⏳ Offen  
**Priorität:** Niedrig  

**Aufgaben:**
- [ ] `.pre-commit-config.yaml` erstellen
- [ ] Pre-commit Framework installieren
- [ ] Hooks konfigurieren:
  - `terraform fmt` (automatische Formatierung)
  - `terraform validate` (Syntax-Validierung)
  - `terraform docs` (automatische Dokumentation)
  - `tflint` (Linting)

**Beispiel:**
```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.88.0
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
```

---

### 8. Multi-Environment Setup mit Workspaces
**Status:** ⏳ Offen  
**Priorität:** Niedrig  
**Beschreibung:** Für spätere Erweiterung auf dev/staging/prod Umgebungen.

**Aufgaben:**
- [ ] Workspace-Konzept dokumentieren
- [ ] Environment-spezifische `.tfvars` Dateien vorbereiten
- [ ] Naming-Convention für Ressourcen anpassen (mit workspace-prefix)

---

### 9. Terraform Module in separates Repository
**Status:** ⏳ Offen  
**Priorität:** Niedrig  
**Beschreibung:** Für Wiederverwendung in mehreren Projekten.

**Aufgaben:**
- [ ] Separates Git-Repository für Module erstellen
- [ ] Module mit Versionen taggen (v1.0.0, v1.1.0, etc.)
- [ ] Module-Source in `main.tf` auf Git-Repo umstellen
- [ ] Module-Registry oder GitHub Releases nutzen

---

### 10. Monitoring und Alerting für Terraform
**Status:** ⏳ Offen  
**Priorität:** Niedrig  

**Aufgaben:**
- [ ] CI/CD Pipeline für Terraform (GitHub Actions, Azure DevOps)
- [ ] Automatisierte `terraform plan` bei Pull Requests
- [ ] Terraform Cloud/Enterprise evaluieren
- [ ] State-Locking überwachen

---

## 📊 Zusätzliche Variablen (Optional)

### 11. Erweiterte Tag-Variablen
**Status:** ⏳ Offen  
**Priorität:** Niedrig  

**Aufgaben:**
- [ ] Variable `project_name` hinzufügen
- [ ] Variable `owner_email` hinzufügen
- [ ] Variable `cost_center` hinzufügen
- [ ] Variable `additional_tags` (map) für benutzerdefinierte Tags

---

## 🔒 Sicherheit

### 12. Purge Protection für Produktion
**Status:** ⏳ Offen  
**Priorität:** Mittel (vor Produktion)  

**Aufgaben:**
- [ ] `purge_protection_enabled = true` für Key Vault in Produktion setzen
- [ ] Environment-basierte Konfiguration (nur für Production)
- [ ] Dokumentation der Auswirkungen

---

## 📝 Dokumentation

### 13. Erweiterte Dokumentation
**Status:** ⏳ Offen  
**Priorität:** Niedrig-Mittel  

**Aufgaben:**
- [ ] Architecture Decision Records (ADRs) erstellen
- [ ] Diagramme hinzufügen (Terraform Graph, Azure Architecture)
- [ ] Troubleshooting-Guide erweitern
- [ ] Migration-Guide für neue Environments

---

## ✅ Abgeschlossen

### ✓ Bootstrap-Modul Struktur implementiert
**Status:** ✅ Erledigt  
**Datum:** 24.10.2025  
- ArgoCD und Grafana-Secrets in `terraform/bootstrap/` verschoben
- Klare Trennung Infrastructure vs. Bootstrap

### ✓ terraform.tfstate aus Git entfernt
**Status:** ✅ Erledigt  
**Datum:** 24.10.2025  
- Kritisches Sicherheitsproblem behoben
- `.tfstate` Dateien werden durch `.gitignore` ausgeschlossen

### ✓ Modulare Architektur umgesetzt
**Status:** ✅ Erledigt  
**Datum:** 24.10.2025  
- Module: aks-cluster, key-vault, blob-storage
- Bootstrap-Modul für Cluster-Setup
- Dokumentation für alle Module

---

## 🎯 Empfohlene Reihenfolge

1. **Sofort:** Tags-System implementieren (#1)
2. **Diese Woche:** Backend-Konfiguration auslagern (#2)
3. **Diese Woche:** Lifecycle-Regeln (#3)
4. **Nächste Woche:** ArgoCD parametrisieren (#4)
5. **Bei Bedarf:** Aufräumen (#6)
6. **Langfristig:** Alle anderen nach Bedarf

---

**Letzte Aktualisierung:** 24. Oktober 2025
