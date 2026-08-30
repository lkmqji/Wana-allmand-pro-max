#!/usr/bin/env bash
# ==============================================================================
# Script d'installation & déploiement automatique pour WANA Backend sur Oracle Cloud
# OS Supporté: Ubuntu 20.04 / 22.04 / 24.04 LTS (Oracle Cloud VM)
# ==============================================================================

set -e

echo "🚀 --- Début du déploiement WANA Backend sur Oracle Cloud --- 🚀"

# 1. Mise à jour du système
echo "📦 Mise à jour des paquets système..."
sudo apt-get update -y && sudo apt-get upgrade -y

# 2. Installation de Node.js 20 LTS, Nginx, Git, Certbot
echo "📦 Installation de Node.js 20 LTS, Nginx, UFW, Git et Certbot..."
sudo apt-get install -y curl wget git nginx ufw certbot python3-certbot-nginx

if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# 3. Installation globale de PM2
echo "📦 Installation de PM2..."
sudo npm install -g pm2

# 4. Configuration du Pare-feu Oracle Cloud (iptables + UFW)
# ATTENTION: Oracle Cloud applique par défaut des règles iptables strictes
echo "🛡️ Configuration du pare-feu pour autoriser HTTP (80), HTTPS (443) et SSH (22)..."
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 443 -j ACCEPT
sudo netfilter-persistent save 2>/dev/null || sudo iptables-save | sudo tee /etc/iptables/rules.v4 > /dev/null 2>&1 || true

sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable || true

# 5. Installation des dépendances Node.js du serveur
echo "📦 Installation des dépendances du projet..."
npm install --omit=dev

# 6. Démarrage de l'application avec PM2
echo "🚀 Lancement de l'application avec PM2..."
if [ -f "ecosystem.config.cjs" ]; then
    pm2 start ecosystem.config.cjs
else
    pm2 start index.js --name "wana-backend"
fi

# Sauvegarder la liste PM2 pour redémarrage auto en cas de reboot de la VM
pm2 save
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u $USER --hp $HOME || true

# 7. Configuration Nginx
echo "🌐 Configuration du Reverse Proxy Nginx..."
if [ -f "nginx-wana.conf" ]; then
    sudo cp nginx-wana.conf /etc/nginx/sites-available/wana-backend
    sudo ln -sf /etc/nginx/sites-available/wana-backend /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo nginx -t && sudo systemctl reload nginx
fi

echo "=============================================================================="
echo "✅ DÉPLOIEMENT TERMINÉ AVEC SUCCÈS !"
echo "=============================================================================="
echo "➡️ Vérifiez l'état de l'application avec: pm2 status"
echo "➡️ Consultez les logs avec: pm2 logs wana-backend"
echo "➡️ Pour ajouter un certificat SSL HTTPS gratuit (Let's Encrypt) :"
echo "   sudo certbot --nginx -d votre-domaine.com"
echo "=============================================================================="
