# Historique des modifications - 30 Août 2026

### 00:04 - Optimisation Mobile du Sélecteur de Mode et Mise à Jour PWA
- **Adaptation responsive du menu déroulant (`PlayDropdown.jsx`)** :
  - Augmentation du `zIndex` à 9999 pour éviter tout conflit de superposition sur mobile.
  - Ajout des contraintes de largeur adaptative (`minWidth: min(270px, calc(100vw - 32px))`, `maxWidth: min(340px, calc(100vw - 20px))`) afin que le sélecteur des 3 modes (Classique, Survie, Tir à la Corde) soit 100% visible sans débordement sur petit écran.
- **Régénération du bundle de production PWA (`dist/`)** :
  - Nouveau build Vite/PWA (`index-DG7JCdqp.js`) pour forcer l'invalidation du cache Service Worker sur smartphone et tablette.

### 00:27 - Ajustements Visuels & Ergonomie du Mode Tir à la Corde (TugOfWarArena.jsx)
- **Suppression des bandeaux superflus** : Retrait du message supérieur « ⚡ Frappe vite pour tirer le rayon ! » et de son conteneur pour aérer la carte de jeu.
- **Correction du texte de la question (`<h3>`)** : Suppression de l'étirement horizontal excessif, ajustement de la taille de police fluide (`clamp(1.35rem, 3.5vw, 1.85rem)`), du retour à la ligne et limitation de la largeur maximale (`maxWidth: 520px`).
- **Repositionnement des touches d'aide** : Déplacement des 9 boutons d'aide rapide (articles allemands `der`, `die`, `das`, `ein`, `eine` et caractères spéciaux `ä`, `ö`, `ü`, `ß`) **en dessous** du champ de saisie pour une ergonomie naturelle.
- **Régénération du bundle de production Vite/PWA** (`index-DdSVPeOd.js`).

### 00:31 - Activation permanente d'Agentation en développement local
- Modification de la condition d'affichage du composant `<Agentation />` dans `App.jsx` : désormais toujours actif en environnement de développement local (`import.meta.env.DEV || standaloneDebug.isLocalDev`) ainsi que pour le compte administrateur.

### 00:33 - Réorganisation ergonomique des touches d'aide (TugOfWarArena.jsx)
- Suppression du séparateur vertical entre les boutons.
- Répartition des touches d'aide en 2 rangées distinctes : les articles (`der`, `die`, `das`, `ein`, `eine`) sur la première ligne et les caractères spéciaux allemands (`ä`, `ö`, `ü`, `ß`) directement en dessous sur la deuxième ligne.
- Nouveau build de production Vite/PWA (`index-D0-W5Mhh.js`).

### 00:38 - Fix d'ancrage en haut et stabilisation du clavier mobile (TugOfWarArena.jsx & TugOfWarBeam.jsx)
- **Ancrage supérieur fixe** : Passage du conteneur en `minHeight: 100dvh` et `justifyContent: flex-start` avec défilement fluide (`overflow-y: auto`) pour ancrer tout le contenu en haut et empêcher le saut/déplacement quand le clavier virtuel s'ouvre.
- **Réduction compacte de la jauge d'énergie (`TugOfWarBeam.jsx`)** : Hauteur passée à 32px et nœud central à 26px pour économiser l'espace vertical sur smartphone.
- **Carte de jeu compacte** : Réduction des marges, du padding et placeholder court (*« Traduction en allemand... »*) pour que l'ensemble (En-tête + Rayon + Question + Saisie + Boutons) reste 100% visible au-dessus du clavier sans être masqué.
- **Rebuild de production Vite/PWA** (`index-B5EciF0k.js`).

### 00:51 - Optimisation des performances Frontend (Vite 8 & PWA)
- **Code Splitting granulaire (`vite.config.js`)** :
  - Découpage du bundle principal via `manualChunks` en modules indépendants : `vendor-react` (React, React-DOM, React-Router), `vendor-firebase` (Firebase Auth/App), `vendor-socket` (Socket.io), `vendor-confetti` (Canvas-Confetti) et `vendor-agentation`.
  - Élimination du fichier monolithique de 1,17 Mo au profit de chunks ciblés et parallélisés.
- **Préchargement et Mise en Cache PWA (`VitePWA` / Workbox)** :
  - Extension des `globPatterns` et de `includeAssets` pour inclure et pré-cacher les assets statiques, effets sonores (SFX / audio `.mp3`, `.wav`) et polices.
  - Augmentation de `maximumFileSizeToCacheInBytes` (15 Mo) pour garantir la mise en cache complète des sons et musiques dès l'installation du Service Worker.
  - Ajout de règles de cache d'exécution (`runtimeCaching`) dédiées pour les polices Google Fonts (`Outfit`, `Syne`, `JetBrains Mono`) avec stratégies `StaleWhileRevalidate` et `CacheFirst`.
- **Minification & Compression Build** :
  - Activation de la minification native optimisée Vite 8, `cssMinify: true`, `cssCodeSplit: true` et désactivation des sourcemaps de production.
  - Régénération réussie du build de production.

### 00:52 - Masquage de l'espace administrateur pour les non-administrateurs (`Profil.jsx`)
- **Restriction d'accès et d'affichage** :
  - La boîte « Mode Administrateur » / « Espace Administrateur » dans l'onglet Profil est désormais strictement conditionnée à `user && isAdmin`.
  - Les utilisateurs standards (non administrateurs) ne voient plus du tout cet encadré ni le bouton pour basculer en mode admin.
  - Les administrateurs authentifiés conservent l'accès complet à leur espace et aux contrôles associés.

### 01:46 - Suppression de l'icône du conteneur dans le modal d'accueil (`OnboardingTour.jsx`)
- **Nettoyage visuel du modal de bienvenue** :
  - Suppression du conteneur d'icône rebondissant (`onboarding-icon-wrapper`) au-dessus des titres d'étapes pour épurer l'affichage et rendre le modal plus compact et clair.

### 02:05 - Ajout des routes Keep-Alive & Health Check pour Render (`server/index.js`)
- **Routes légères de maintien en éveil** :
  - Ajout des routes `GET /`, `GET /health` et `GET /api/health` qui retournent immédiatement un statut `200 OK` avec le temps d'activité (`uptime`) et l'horodatage.
  - Permet d'éviter le "Cold Start" sur Render.com via un service de ping périodique externe (ex: cron-job.org) sans solliciter la base de données MongoDB.

### 02:26 - Optimisation SEO & Performance Web du fichier racine (`client/index.html`)
- **Implémentation des balises Resource Hints (`preconnect` et `dns-prefetch`)** :
  - *Google Fonts* : Pré-résolution DNS et pré-connexion TLS avec `crossorigin` pour `fonts.googleapis.com` et `fonts.gstatic.com` afin d'éliminer le blocage du rendu lié au téléchargement des polices.
  - *Backend Render (API & WebSockets)* : Anticipation de la connexion TCP/TLS et résolution DNS pour les serveurs Render (`wana-allmand.onrender.com` et `onrender.com`).
  - *Firebase Authentication & Services Google* : Optimisation des requêtes d'authentification et des jetons d'accès via `identitytoolkit.googleapis.com`, `securetoken.googleapis.com` et `wana-allmand.firebaseapp.com`.
- **Désactivation du délai de 300ms au tap sur Safari iOS** :
  - Configuration de la balise `<meta name="viewport">` avec `maximum-scale=1.0, user-scalable=no, viewport-fit=cover` pour supprimer le délai natif de 300ms du "double-tap-to-zoom" et rendre les boutons 100% réactifs.

### 13:10 - Renommage de l'application en « WANA allmand pro MAX »
- **Mise à jour des métadonnées de l'application et PWA** :
  - Modification du titre de page HTML (`<title>`) et de la balise mobile (`apple-mobile-web-app-title`) dans `client/index.html`.
  - Mise à jour du nom complet et du nom court dans le fichier de manifeste PWA (`client/public/manifest.webmanifest`) et dans la configuration du plugin Vite PWA (`client/vite.config.js`).
- **Harmonisation des composants d'interface utilisateur** :
  - Écran de démarrage ([TitleScreen.jsx](file:///client/src/components/TitleScreen.jsx)) : Mise à jour du grand titre principal en `WANA ALLMAND PRO MAX`.
  - Barre de navigation et menu latéral ([Layout.jsx](file:///client/src/components/Layout.jsx)) : Mise à jour de l'en-tête mobile et de la barre latérale desktop.
  - Page d'accueil ([Home.jsx](file:///client/src/components/Home.jsx)) : Titre de l'arène de jeu mis à jour en `WANA ALLMAND PRO MAX`.
  - Écran de connexion ([App.jsx](file:///client/src/App.jsx)) : Logo et titre d'en-tête mis à jour en `WANA ALLMAND PRO MAX`.
  - Modal d'installation PWA ([InstallGate.jsx](file:///client/src/components/InstallGate.jsx)) : Textes d'instructions, libellés d'icône et sous-titres actualisés.
  - Visite guidée d'accueil ([OnboardingTour.jsx](file:///client/src/components/OnboardingTour.jsx)) : Titre de bienvenue actualisé.
### 13:17 - Configuration du Déploiement Public (Vercel & Oracle Cloud)
- **Configuration Vercel pour le Frontend (`client/vercel.json` et `vercel.json`)** :
  - Mise en place de la configuration Vercel avec redirection SPA (`rewrites`), sécurisation par en-têtes HTTP (`X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`) et politique de cache longue durée pour les sons et assets.
  - Création du fichier d'exemple des variables d'environnement client (`client/.env.example`).
- **Configuration et Scripts pour le Backend sur Oracle Cloud (`server/`)** :
  - Création du fichier de configuration PM2 (`server/ecosystem.config.cjs`) pour le redémarrage automatique et la gestion de la mémoire.
  - Création du script d'installation et de déploiement automatique (`server/deploy-oracle.sh`) pour VM Ubuntu/Debian sur Oracle Cloud (installation Node.js 20, Nginx, Certbot SSL, configuration pare-feu iptables/UFW).
  - Création de la configuration Nginx Reverse Proxy avec support des WebSockets (`server/nginx-wana.conf`).
  - Création du `Dockerfile` et `docker-compose.yml` pour le support de déploiement conteneurisé.
  - Création du fichier d'exemple des variables d'environnement serveur (`server/.env.example`).
### 13:22 - Nettoyage et Suppression des Doublons du Projet
- **Suppression du lien de jonction dupliqué (`Wana-Allmand-2-main`)** :
  - Suppression de la jonction de dossier à la racine du projet qui créait une réplique virtuelle complète de `Wana allmand pro MAX`.
- **Suppression du dossier de build dupliqué (`client/dist/`)** :
  - Suppression du dossier de distribution contenant des doublons statiques lourds (notamment le fichier audio `bgm-main.mp3` de 12,8 Mo, `favicon.svg` et `icons.svg` déjà présents dans `client/public/`).
- **Unification de la configuration Vercel (`vercel.json`)** :
  - Centralisation de tous les en-têtes de sécurité et de mise en cache au sein du fichier racine `vercel.json` et suppression du doublon `client/vercel.json`.
- **Vérification de l'intégrité et des dépendances** :
  - Contrôle par hachage SHA-256 de tous les fichiers du projet (0 doublon restant).
  - Vérification de l'absence de dossiers `node_modules`.

### 13:37 - Résolution de l'Erreur de Build Vercel (`cd client && npm install`)
- **Correction de la configuration Vercel (`vercel.json` et `client/vercel.json`)** :
  - Suppression de la directive personnalisée `installCommand: "cd client && npm install"` qui provoquait une erreur 1 immédiate sur Vercel lorsque le dossier racine du projet (*Root Directory*) était défini sur `client`.
  - Ajout d'un fichier [client/vercel.json](file:///client/vercel.json) dédié gérant automatiquement les règles de réécriture SPA (`/index.html`) et les en-têtes HTTP de sécurité/cache.
  - Mise à jour du fichier racine [vercel.json](file:///vercel.json) pour assurer la compatibilité quel que soit le dossier racine choisi sur Vercel (`./` ou `client`).

