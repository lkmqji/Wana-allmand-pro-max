# 🚀 Guide de Déploiement Public : Vercel (Frontend) + Oracle Cloud (Backend)

Ce guide détaille étape par étape la mise en ligne publique et sécurisée de l'application **WANA (Allmand)** :
- **Frontend (Client Vite/React)** : Déployé sur **Vercel** (CDN mondial ultra-rapide, HTTPS automatique).
- **Backend (Serveur Node.js / WebSockets Socket.io)** : Déployé sur **Oracle Cloud Infrastructure (OCI)** (VM Always Free, persistance des parties multijoueur).

---

## 📋 Architecture Globale

```
+---------------------------+              +--------------------------------------+
|          UTILISATEUR      |              |             ORACLE CLOUD             |
|   (Navigateur / Mobile)   |              |             (Backend VM)             |
+-------------+-------------+              +------------------+-------------------+
              |                                               ^
     1. HTTPS | (HTML / JS / Assets)                          | 2. HTTPS + WSS (Socket.io)
              v                                               |
+-------------+-------------+                                 |
|          VERCEL           |                                 |
|     (Frontend React)      +---------------------------------+
|   https://votre-app.vercel.app
+---------------------------+
```

---

## 🛠️ ÉTAPE 1 : Déploiement du Backend sur Oracle Cloud

> ⚠️ **Important pour les WebSockets / HTTPS** : Le frontend sur Vercel sera servi en `https://`. Les navigateurs modernes bloquent les requêtes vers du `http://` non sécurisé (erreur *Mixed Content*). Votre backend Oracle Cloud doit donc être accessible en **HTTPS** (avec un nom de domaine ou sous-domaine gratuit via DuckDNS/Cloudflare + Certbot Let's Encrypt).

### 1.1 Créer l'instance sur Oracle Cloud (Always Free)
1. Rendez-vous sur votre console [Oracle Cloud](https://cloud.oracle.com/).
2. Menu **Compute** (Calcul) ➔ **Instances** ➔ **Create Instance**.
3. **Image** : Choisissez **Ubuntu 22.04** ou **Ubuntu 24.04**.
4. **Shape** :
   - Soit *Ampere (ARM)* : VM.Standard.A1.Flex (jusqu'à 4 OCPU et 24 Go RAM gratuits).
   - Soit *AMD (x86)* : VM.Standard.E2.1.Micro.
5. Téléchargez votre **clé privée SSH** (`.key` ou `.pem`).
6. Cliquez sur **Create**.

---

### 1.2 Ouvrir les ports dans Oracle Cloud (Security List)
Par défaut, Oracle Cloud bloque tout le trafic entrant sauf le port 22 (SSH).
1. Dans la page de votre instance, cliquez sur votre **Subnet** (Sous-réseau).
2. Cliquez sur votre **Default Security List**.
3. Cliquez sur **Add Ingress Rules** et ajoutez :
   - **Source CIDR** : `0.0.0.0/0`
   - **IP Protocol** : `TCP`
   - **Destination Port Range** : `80,443,3001`
   - **Description** : `Autoriser HTTP, HTTPS et API Backend`
4. Cliquez sur **Add Ingress Rules**.

---

### 1.3 Se connecter à la VM et installer le serveur
1. Ouvrez votre terminal (PowerShell ou Bash) et connectez-vous :
   ```bash
   ssh -i /chemin/vers/votre-cle.key ubuntu@<IP_PUBLIQUE_ORACLE>
   ```

2. Clonez votre dépôt GitHub ou transférez le dossier `server` :
   ```bash
   git clone https://github.com/VOTRE_USER/VOTRE_REPO.git
   cd VOTRE_REPO/server
   ```

3. Créez et configurez le fichier `.env` :
   ```bash
   cp .env.example .env
   nano .env
   ```
   Remplissez les valeurs réelles :
   ```env
   PORT=3001
   MONGODB_URI=mongodb+srv://<user>:<password>@cluster0.xxxxx.mongodb.net/wana_allmand?retryWrites=true&w=majority
   ADMIN_UID=votre_uid_firebase_admin
   GEMINI_API_KEY=votre_cle_gemini_optionnelle
   NODE_ENV=production
   ```
   *(Sauvegardez avec `Ctrl+O` puis quittez avec `Ctrl+X`)*.

4. Rendez le script exécutable et lancez l'installation automatique :
   ```bash
   chmod +x deploy-oracle.sh
   ./deploy-oracle.sh
   ```
   Ce script va automatiquement :
   - Mettre à jour la VM et installer Node.js 20, Nginx, PM2, Certbot, UFW.
   - Ouvrir les ports pare-feu internes d'Oracle Linux/Ubuntu.
   - Installer les modules npm et démarrer le serveur avec PM2 (avec auto-démarrage au boot).
   - Configurer Nginx en Reverse Proxy pour supporter les WebSockets Socket.io.

---

### 1.4 Configurer le Domaine & Certificat SSL HTTPS (Let's Encrypt)
1. Pointez votre domaine (ou sous-domaine, ex: `api.mondomaine.com` ou un domaine gratuit DuckDNS `mon-app-api.duckdns.org`) vers l'adresse IP publique de votre VM Oracle.
2. Éditez `/etc/nginx/sites-available/wana-backend` :
   ```bash
   sudo nano /etc/nginx/sites-available/wana-backend
   ```
   Remplacez `votre-domaine.com api.votre-domaine.com` par votre vrai domaine (ex: `api.mondomaine.com`).
3. Rechargez Nginx :
   ```bash
   sudo systemctl reload nginx
   ```
4. Obtenez votre certificat SSL gratuit en 1 commande :
   ```bash
   sudo certbot --nginx -d api.mondomaine.com
   ```
5. Testez dans votre navigateur : ouvrez `https://api.mondomaine.com/health` ➔ Vous devriez voir `{"status":"ok","message":"Server is awake and healthy"}`.

---

## 🌐 ÉTAPE 2 : Déploiement du Frontend sur Vercel

1. Rendez-vous sur [Vercel](https://vercel.com/) et connectez-vous avec votre compte GitHub.
2. Cliquez sur **Add New...** ➔ **Project**.
3. Importez votre dépôt GitHub.
4. Dans les paramètres du projet (**Project Settings**) :
   - **Framework Preset** : `Vite`
   - **Root Directory** : Cliquez sur **Edit** et sélectionnez le dossier `client`.
   - **Build Command** : `npm run build` (détecté automatiquement).
   - **Output Directory** : `dist` (détecté automatiquement).
5. Dépliez la section **Environment Variables** et ajoutez :
   - `VITE_API_URL` : `https://api.mondomaine.com` *(l'URL HTTPS de votre backend Oracle Cloud)*.
   - `VITE_ADMIN_UID` : *(Votre UID Firebase administrateur)*.
6. Cliquez sur **Deploy**.
7. En quelques secondes, votre site est en ligne sur une URL du type `https://wana-allmand.vercel.app` !

---

## 🔑 ÉTAPE 3 : Autoriser le Domaine sur Firebase Authentication

Pour que la connexion Google fonctionne sur le site en ligne :
1. Rendez-vous sur la [Console Firebase](https://console.firebase.google.com/).
2. Sélectionnez votre projet `wana-allmand`.
3. Allez dans **Authentication** ➔ Onglet **Settings** (Paramètres) ➔ **Authorized domains** (Domaines autorisés).
4. Cliquez sur **Add domain** et ajoutez :
   - Votre domaine Vercel : `wana-allmand.vercel.app` (ou votre nom de domaine personnalisé).
5. Cliquez sur **Save**.

---

## 🛠️ Commandes de Maintenance utiles sur Oracle Cloud (PM2)

| Action | Commande |
| :--- | :--- |
| **Voir l'état du serveur** | `pm2 status` |
| **Voir les logs en direct** | `pm2 logs wana-backend` |
| **Redémarrer le serveur** | `pm2 restart wana-backend` |
| **Arrêter le serveur** | `pm2 stop wana-backend` |
| **Mettre à jour le code** | `git pull && npm install && pm2 restart wana-backend` |
| **Tester Nginx** | `sudo nginx -t` |
| **Redémarrer Nginx** | `sudo systemctl restart nginx` |
