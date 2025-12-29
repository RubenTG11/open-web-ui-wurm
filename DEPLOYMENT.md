# 🚀 Wurm-Ki Deployment Guide für Coolify

Diese Anleitung erklärt Schritt für Schritt, wie du Wurm-Ki mit Coolify und Docker deployest.

## 📋 Voraussetzungen

1. **Coolify Server** (installiert und läuft)
   - Mindestens 2GB RAM
   - 20GB freier Speicherplatz
   - Domain/Subdomain (z.B. `wurm-ki.yourdomain.com`)

2. **Ollama Server** (für LLM Models)
   - Kann auf demselben oder einem separaten Server laufen
   - Installation: https://ollama.ai/download

3. **Git Repository**
   - Dieser Code muss in einem Git-Repository sein (GitHub/GitLab/Gitea)

---

## 🎯 Option 1: Deployment via Coolify (Empfohlen)

### Schritt 1: Repository vorbereiten

1. **Code ins Git-Repository pushen:**
   ```bash
   cd /home/ruben/open-webui
   git add .
   git commit -m "Prepare Wurm-Ki for deployment"
   git push origin main
   ```

2. **Wichtig:** Stelle sicher, dass diese Dateien im Repository sind:
   - ✅ `Dockerfile`
   - ✅ `docker-compose.yml`
   - ✅ `.dockerignore`
   - ✅ `.env.production` (als Template)

### Schritt 2: Coolify Projekt erstellen

1. **In Coolify einloggen**
   - Öffne dein Coolify Dashboard

2. **Neues Projekt erstellen:**
   - Klicke auf "New Project"
   - Name: `wurm-ki`
   - Optional: Environment wählen (Production)

3. **Neue Ressource hinzufügen:**
   - Wähle "New Resource"
   - Typ: **"Docker Compose"** oder **"Dockerfile"**

### Schritt 3: Git-Repository verbinden

1. **Source auswählen:**
   - Wähle deine Git-Quelle (GitHub/GitLab/Gitea)
   - Repository: Dein Wurm-Ki Repository
   - Branch: `main` (oder dein Deployment-Branch)

2. **Build-Konfiguration:**
   - Dockerfile Path: `./Dockerfile` (Standard)
   - Docker Compose: Wenn du docker-compose nutzen willst: `./docker-compose.yml`

### Schritt 4: Environment Variables konfigurieren

Füge diese Environment Variables in Coolify hinzu:

**Wichtige Variablen:**
```bash
# 1. SECURITY (KRITISCH!)
WEBUI_SECRET_KEY=<generiere-einen-random-string>
# Generieren: python -c "import secrets; print(secrets.token_hex(32))"

# 2. OLLAMA VERBINDUNG
OLLAMA_BASE_URL=http://host.docker.internal:11434
# Wenn Ollama auf anderem Server: http://OLLAMA_SERVER_IP:11434

# 3. AUTHENTICATION
ENABLE_SIGNUP=false
ENABLE_LOGIN_FORM=true
DEFAULT_USER_ROLE=user

# 4. PRIVACY
SCARF_NO_ANALYTICS=true
DO_NOT_TRACK=true
ANONYMIZED_TELEMETRY=false

# 5. NETWORKING
CORS_ALLOW_ORIGIN=*
FORWARDED_ALLOW_IPS=*
```

**Optional (wenn du OpenAI nutzen willst):**
```bash
OPENAI_API_KEY=sk-...
OPENAI_API_BASE_URL=https://api.openai.com/v1
```

### Schritt 5: Domain konfigurieren

1. **Domain hinzufügen:**
   - In Coolify unter "Domains"
   - Füge deine Domain hinzu: `wurm-ki.yourdomain.com`
   - SSL wird automatisch via Let's Encrypt eingerichtet

2. **Port Mapping:**
   - Container Port: `8080` (Standard von Wurm-Ki)
   - Public Port: `80` oder `443` (Coolify managed das automatisch)

### Schritt 6: Volume/Storage konfigurieren

**Wichtig:** Persistente Daten speichern!

1. **Volume hinzufügen:**
   - Path im Container: `/app/backend/data`
   - Host Path: `/var/lib/coolify/volumes/wurm-ki-data`

2. **Datenbank & Uploads:**
   - SQLite DB wird in `/app/backend/data` gespeichert
   - User-Uploads werden in `/app/backend/data/uploads` gespeichert

### Schritt 7: Deployment starten

1. **Deploy Button klicken** 🚀
2. **Build-Log beobachten:**
   - Der Build dauert ca. 5-10 Minuten beim ersten Mal
   - Frontend wird mit Node.js gebaut
   - Backend Python-Dependencies werden installiert

3. **Status prüfen:**
   - Wenn "Running" → Deployment erfolgreich! ✅

### Schritt 8: Ersten Admin-User erstellen

1. **Beim ersten Start:**
   - Öffne `https://wurm-ki.yourdomain.com`
   - Das System erkennt, dass keine Users existieren
   - Du kannst den ersten Admin-Account erstellen

2. **Wichtig:** Nach dem ersten Admin-Login:
   - Gehe zu Admin Panel
   - Erstelle weitere User-Accounts (Signup ist deaktiviert)

---

## 🎯 Option 2: Lokales Testing mit Docker Compose

Vor dem Production-Deployment kannst du lokal testen:

### 1. Environment File erstellen

```bash
cd /home/ruben/open-webui
cp .env.production .env
```

Editiere `.env` und setze die Werte:
```bash
nano .env
```

### 2. Docker Compose starten

```bash
# Build und Start
docker-compose up -d

# Logs ansehen
docker-compose logs -f

# Stoppen
docker-compose down
```

### 3. Testen

Öffne: `http://localhost:3000`

---

## 🔧 Ollama Setup

### Option A: Ollama auf demselben Server

```bash
# Ollama installieren
curl -fsSL https://ollama.com/install.sh | sh

# Model herunterladen (z.B. Llama 3.2)
ollama pull llama3.2

# Ollama läuft automatisch auf Port 11434
# In Wurm-Ki: OLLAMA_BASE_URL=http://host.docker.internal:11434
```

### Option B: Ollama auf separatem Server

```bash
# Auf dem Ollama-Server
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2

# Ollama für externe Verbindungen öffnen
# /etc/systemd/system/ollama.service
OLLAMA_HOST=0.0.0.0:11434

# In Wurm-Ki: OLLAMA_BASE_URL=http://OLLAMA_SERVER_IP:11434
```

---

## 📊 Monitoring & Logs

### In Coolify:

1. **Logs ansehen:**
   - Coolify Dashboard → Dein Service → Logs
   - Real-time Logs verfügbar

2. **Metriken:**
   - CPU, RAM, Network Usage
   - Container Health Status

### Via Docker:

```bash
# Container Logs
docker logs wurm-ki -f

# Container Status
docker ps | grep wurm-ki

# Container inspizieren
docker inspect wurm-ki
```

---

## 🔒 Sicherheits-Checkliste

- [ ] `WEBUI_SECRET_KEY` ist ein zufälliger String (nicht "changeme")
- [ ] `ENABLE_SIGNUP=false` (nur Admins können Users erstellen)
- [ ] SSL/HTTPS ist aktiviert (via Coolify Let's Encrypt)
- [ ] Firewall erlaubt nur Port 80/443
- [ ] Backups sind konfiguriert (siehe unten)
- [ ] Strong Passwords für Admin-Accounts

---

## 💾 Backup & Restore

### Backup erstellen:

```bash
# Volume-Backup (Datenbank + Uploads)
docker run --rm \
  -v wurm-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/wurm-ki-backup-$(date +%Y%m%d).tar.gz -C /data .
```

### Restore:

```bash
# Backup wiederherstellen
docker run --rm \
  -v wurm-data:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/wurm-ki-backup-YYYYMMDD.tar.gz -C /data
```

### Automatisches Backup (Cronjob):

```bash
# Crontab editieren
crontab -e

# Täglich um 2 Uhr nachts Backup
0 2 * * * cd /var/backups && docker run --rm -v wurm-data:/data -v $(pwd):/backup alpine tar czf /backup/wurm-ki-backup-$(date +\%Y\%m\%d).tar.gz -C /data .
```

---

## 🔄 Updates deployen

### Via Coolify:

1. **Code ändern und pushen:**
   ```bash
   git add .
   git commit -m "Update XYZ"
   git push origin main
   ```

2. **In Coolify:**
   - Gehe zu deinem Service
   - Klicke "Redeploy"
   - Coolify pullt neuen Code und baut neu

### Manuell:

```bash
# Repository pullen
cd /home/ruben/open-webui
git pull

# Docker Image neu bauen
docker-compose build --no-cache

# Container neu starten
docker-compose down
docker-compose up -d
```

---

## 🐛 Troubleshooting

### Problem: "Cannot connect to Ollama"

**Lösung:**
```bash
# 1. Prüfe ob Ollama läuft
curl http://localhost:11434/api/version

# 2. Prüfe OLLAMA_BASE_URL in Environment
docker inspect wurm-ki | grep OLLAMA_BASE_URL

# 3. Wenn auf anderem Server: Firewall prüfen
telnet OLLAMA_SERVER_IP 11434
```

### Problem: "Build Failed"

**Lösung:**
```bash
# 1. Logs checken
docker-compose logs

# 2. Cache löschen und neu bauen
docker-compose build --no-cache

# 3. Speicherplatz prüfen
df -h
```

### Problem: "Cannot create admin user"

**Lösung:**
```bash
# 1. Container logs prüfen
docker logs wurm-ki

# 2. Datenbank-Volume prüfen
docker volume inspect wurm-data

# 3. Notfall: Volume löschen und neu starten
docker-compose down -v
docker-compose up -d
```

---

## 📞 Support & Hilfe

- **Open WebUI Docs:** https://docs.openwebui.com
- **Coolify Docs:** https://coolify.io/docs
- **Ollama Docs:** https://ollama.ai/docs

---

## 🎉 Fertig!

Deine Wurm-Ki Instanz sollte jetzt laufen! 🚀

**Wichtige URLs:**
- Wurm-Ki: `https://wurm-ki.yourdomain.com`
- Coolify Dashboard: `https://coolify.yourdomain.com`
- Ollama API: `http://your-server:11434`

**Nächste Schritte:**
1. ✅ Admin-Account erstellen
2. ✅ User-Accounts für Team erstellen
3. ✅ Modelle in Ollama laden (`ollama pull llama3.2`)
4. ✅ Backup-Strategie testen
5. ✅ Team einladen und schulen
