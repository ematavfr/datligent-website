# DATLIGENT - Infrastructure DevOps & MLOps

## 🚀 Vue d'ensemble

Infrastructure complète pour le site web professionnel **DATLIGENT**, avec déploiement Docker automatisé, reverse proxy Traefik, SSL automatique et monitoring intégré.

## 🌐 URLs d'accès

- **Site principal** : https://servops.datligent.fr
- **Dashboard Traefik** : https://traefik.servops.datligent.fr
- **Monitoring Prometheus** : https://monitoring.servops.datligent.fr
- **Dashboard Grafana** : https://dashboard.servops.datligent.fr

## 📋 Services inclus

### 🔧 **Infrastructure principale**
- **NGINX** - Serveur web avec configuration optimisée
- **Traefik v3** - Reverse proxy avec SSL automatique (Let's Encrypt)
- **Docker Compose** - Orchestration des services

### 📊 **Monitoring et observabilité**
- **Prometheus** - Collecte de métriques
- **Grafana** - Visualisation et dashboards
- **InfluxDB** - Base de données de métriques
- **Health checks** - Surveillance de la santé des services

### 🛡️ **Sécurité**
- **SSL/TLS automatique** via Let's Encrypt
- **Headers de sécurité** configurés
- **Rate limiting** et protection DDoS
- **Authentification** pour les services d'administration

### 💾 **Sauvegarde et maintenance**
- **Sauvegardes automatiques** quotidiennes
- **Logs centralisés** et rotation
- **Scripts de déploiement** automatisés

## 🛠️ Installation et déploiement

### Prérequis

```bash
# Installation Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Installation Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Configuration DNS

Configurer les enregistrements DNS suivants :

```
servops.datligent.fr          A    YOUR_SERVER_IP
traefik.servops.datligent.fr  A    YOUR_SERVER_IP
monitoring.servops.datligent.fr A  YOUR_SERVER_IP
dashboard.servops.datligent.fr  A  YOUR_SERVER_IP
```

### Déploiement rapide

```bash
# Cloner le repository
git clone https://github.com/ematavfr/datligent-website.git
cd datligent-website

# Configuration de l'environnement
cp .env.example .env
# Éditer le fichier .env avec vos paramètres

# Rendre le script exécutable
chmod +x deploy.sh

# Déploiement en production
./deploy.sh production
```

### Déploiement manuel

```bash
# Configuration de l'environnement
cp .env.example .env

# Création des répertoires
mkdir -p backups logs ssl-certs

# Lancement des services
docker-compose up -d --build

# Vérification du statut
docker-compose ps
docker-compose logs -f
```

## 📁 Structure du projet

```
datligent-website/
├── 🌐 Site web
│   ├── index.html              # Page principale
│   └── assets/                 # Ressources statiques
├── 🐳 Docker
│   ├── Dockerfile              # Image NGINX personnalisée
│   ├── docker-compose.yml      # Configuration des services
│   └── .env.example           # Variables d'environnement
├── 🔀 Reverse Proxy
│   └── traefik/
│       ├── traefik.yml        # Configuration principale
│       └── dynamic.yml        # Configuration dynamique
├── 🌐 Serveur Web
│   └── nginx/
│       ├── nginx.conf         # Configuration NGINX
│       └── default.conf       # Configuration du site
├── 📊 Monitoring
│   ├── monitoring/
│   │   └── prometheus.yml     # Configuration Prometheus
│   └── grafana/               # Dashboards Grafana
├── 🔧 Scripts
│   ├── deploy.sh              # Script de déploiement
│   └── backup.sh              # Script de sauvegarde
└── 📚 Documentation
    ├── README.md              # Ce fichier
    └── docs/                  # Documentation détaillée
```

## ⚙️ Configuration avancée

### Variables d'environnement (.env)

```bash
# Configuration générale
DOMAIN=servops.datligent.fr
EMAIL=contact@datligent.fr

# Authentification
TRAEFIK_DASHBOARD_USER=admin
TRAEFIK_DASHBOARD_PASSWORD=your-secure-password

# Monitoring
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=your-secure-password
```

### Configuration SSL

Le SSL est automatiquement configuré via Let's Encrypt. Pour un certificat personnalisé :

```yaml
# Dans traefik/dynamic.yml
tls:
  certificates:
    - certFile: /ssl-certs/servops.datligent.fr.crt
      keyFile: /ssl-certs/servops.datligent.fr.key
```

### Scaling et performance

```bash
# Ajuster les ressources
docker-compose up -d --scale datligent-web=3

# Monitoring des performances
docker stats
docker-compose top
```

## 📊 Monitoring et alertes

### Métriques disponibles

- **Trafic web** : Requests/sec, response time, status codes
- **Infrastructure** : CPU, RAM, Disk, Network
- **Services** : Health checks, uptime, errors
- **SSL** : Expiration des certificats

### Dashboards Grafana

Accès : https://dashboard.servops.datligent.fr
- Dashboard principal DATLIGENT
- Métriques infrastructure
- Monitoring Traefik
- Alertes et notifications

## 🔒 Sécurité

### Headers de sécurité configurés

```
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

### Rate limiting

- 100 requests par minute par IP
- Protection DDoS intégrée
- Blocage des bots malveillants

## 💾 Sauvegarde et restauration

### Sauvegarde automatique

```bash
# Configuration dans docker-compose.yml
# Sauvegarde quotidienne à 2h du matin
BACKUP_SCHEDULE=0 2 * * *
```

### Sauvegarde manuelle

```bash
# Sauvegarde complète
./backup.sh

# Sauvegarde spécifique
docker run --rm -v datligent_traefik-ssl-certs:/data -v $PWD/backups:/backup alpine tar czf /backup/ssl-$(date +%Y%m%d).tar.gz -C /data .
```

### Restauration

```bash
# Arrêt des services
docker-compose down

# Restauration des volumes
docker run --rm -v datligent_traefik-ssl-certs:/data -v $PWD/backups:/backup alpine tar xzf /backup/ssl-20250523.tar.gz -C /data

# Redémarrage
docker-compose up -d
```

## 🔧 Maintenance

### Commandes utiles

```bash
# Statut des services
docker-compose ps

# Logs en temps réel
docker-compose logs -f

# Redémarrage d'un service
docker-compose restart datligent-web

# Mise à jour des images
docker-compose pull
docker-compose up -d

# Nettoyage
docker system prune -f
```

### Mise à jour

```bash
# Sauvegarde avant mise à jour
./backup.sh

# Mise à jour du code
git pull origin main

# Redéploiement
./deploy.sh production
```

## 🐛 Dépannage

### Vérifications communes

```bash
# Vérifier les ports
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# Vérifier DNS
nslookup servops.datligent.fr

# Logs détaillés
docker-compose logs traefik
docker-compose logs datligent-web

# Tester SSL
curl -I https://servops.datligent.fr
```

### Problèmes fréquents

1. **Certificat SSL non généré**
   - Vérifier la configuration DNS
   - Vérifier les ports 80/443 ouverts

2. **Service non accessible**
   - Vérifier les labels Traefik
   - Vérifier la configuration réseau

3. **Monitoring non fonctionnel**
   - Vérifier les volumes Prometheus
   - Vérifier la configuration Grafana

## 📞 Support

- **Email** : contact@datligent.fr
- **Documentation** : Dossier `/docs`
- **Issues** : GitHub Issues

## 📄 Licence

© 2025 DATLIGENT. Tous droits réservés.

---

*DATLIGENT - Expert DevOps & MLOps - Transformez votre infrastructure en plateforme intelligente*