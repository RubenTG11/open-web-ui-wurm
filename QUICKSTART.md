# ⚡ Wurm-Ki Quickstart

Schnelleinstieg für Wurm-Ki Deployment.

## 🎯 Lokales Testing (5 Minuten)

```bash
# 1. Environment konfigurieren
cp .env.production .env
nano .env  # WEBUI_SECRET_KEY und OLLAMA_BASE_URL setzen

# 2. Deployment starten
./scripts/deploy-local.sh

# 3. Öffnen
# Browser: http://localhost:3000
```

## 🚀 Production Deployment mit Coolify (10 Minuten)

### Voraussetzungen
- Coolify Server läuft
- Git Repository (GitHub/GitLab/Gitea)
- Domain/Subdomain (z.B. wurm-ki.yourdomain.com)
- Ollama Server (lokal oder remote)

### Schritte

**1. Code ins Repository pushen:**
```bash
git add .
git commit -m "Deploy Wurm-Ki"
git push origin main
```

**2. In Coolify:**
1. New Project → `wurm-ki`
2. New Resource → Docker Compose (oder Dockerfile)
3. Git Source verbinden → Repository auswählen
4. Branch: `main`

**3. Environment Variables setzen:**

Klicke auf "Environment Variables" und füge hinzu:

```bash
# Kritisch!
WEBUI_SECRET_KEY=<random-string-hier>

# Ollama Verbindung
OLLAMA_BASE_URL=http://host.docker.internal:11434

# Security
ENABLE_SIGNUP=false
ENABLE_LOGIN_FORM=true

# Privacy
SCARF_NO_ANALYTICS=true
DO_NOT_TRACK=true
ANONYMIZED_TELEMETRY=false
```

**4. Domain konfigurieren:**
- Domain: `wurm-ki.yourdomain.com`
- SSL: Auto (Let's Encrypt)
- Port: 8080 → 443

**5. Volume hinzufügen:**
- Container Path: `/app/backend/data`
- Host Path: `/var/lib/coolify/volumes/wurm-ki-data`

**6. Deploy klicken! 🚀**

Fertig! Wurm-Ki läuft unter: `https://wurm-ki.yourdomain.com`

## 🔐 Ersten Admin erstellen

1. Öffne `https://wurm-ki.yourdomain.com`
2. System erkennt: Keine User → Admin-Registrierung
3. Erstelle Admin-Account
4. Fertig! ✅

## 📚 Weitere Infos

Detaillierte Anleitung: [DEPLOYMENT.md](./DEPLOYMENT.md)

---

## 🆘 Probleme?

**Ollama nicht erreichbar:**
```bash
# Prüfen
curl http://localhost:11434/api/version

# Ollama starten
ollama serve
```

**Build schlägt fehl:**
```bash
# Logs anschauen
docker-compose logs -f

# Clean rebuild
docker-compose build --no-cache
```

**Kann nicht einloggen:**
```bash
# Container neu starten
docker-compose restart

# Logs prüfen
docker-compose logs -f wurm-ki
```
