#!/bin/bash

# Script de déploiement automatisé pour DATLIGENT
# Usage: ./deploy.sh [production|staging|development]

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-development}
PROJECT_NAME="datligent"
DOMAIN="servops.datligent.fr"

# Fonctions utilitaires
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Vérification des prérequis
check_requirements() {
    log "Vérification des prérequis..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker n'est pas installé"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose n'est pas installé"
        exit 1
    fi
    
    success "Prérequis vérifiés"
}

# Configuration de l'environnement
setup_environment() {
    log "Configuration de l'environnement: $ENVIRONMENT"
    
    if [ ! -f .env ]; then
        if [ -f .env.example ]; then
            cp .env.example .env
            warning "Fichier .env créé depuis .env.example. Veuillez le personnaliser."
        else
            error "Fichier .env.example introuvable"
            exit 1
        fi
    fi
    
    # Création des répertoires nécessaires
    mkdir -p backups logs ssl-certs
    
    # Permissions pour les certificats SSL
    chmod 600 ssl-certs 2>/dev/null || true
    
    success "Environnement configuré"
}

# Validation de la configuration DNS
check_dns() {
    log "Vérification de la configuration DNS..."
    
    if nslookup $DOMAIN &> /dev/null; then
        success "DNS configuré pour $DOMAIN"
    else
        warning "DNS non configuré pour $DOMAIN. Le déploiement peut échouer."
        read -p "Continuer quand même ? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Arrêt des services existants
stop_services() {
    log "Arrêt des services existants..."
    docker-compose down --remove-orphans || true
    success "Services arrêtés"
}

# Construction et démarrage des services
start_services() {
    log "Construction et démarrage des services..."
    
    case $ENVIRONMENT in
        production)
            docker-compose -f docker-compose.yml up -d --build
            ;;
        staging)
            docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d --build
            ;;
        development)
            docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
            ;;
        *)
            error "Environnement non reconnu: $ENVIRONMENT"
            exit 1
            ;;
    esac
    
    success "Services démarrés"
}

# Vérification de la santé des services
health_check() {
    log "Vérification de la santé des services..."
    
    # Attente du démarrage des services
    sleep 10
    
    # Vérification du site web
    if curl -f http://localhost/health &> /dev/null; then
        success "Site web opérationnel"
    else
        warning "Site web non accessible localement"
    fi
    
    # Vérification de Traefik
    if docker ps | grep -q traefik; then
        success "Traefik opérationnel"
    else
        error "Traefik non opérationnel"
    fi
    
    # Affichage des logs récents
    log "Logs récents des services:"
    docker-compose logs --tail=10
}

# Nettoyage des ressources inutilisées
cleanup() {
    log "Nettoyage des ressources inutilisées..."
    docker system prune -f --volumes
    success "Nettoyage terminé"
}

# Sauvegarde avant déploiement
backup() {
    log "Création d'une sauvegarde..."
    
    BACKUP_DIR="./backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    # Sauvegarde des volumes Docker
    docker run --rm -v datligent_traefik-ssl-certs:/data -v "$PWD/$BACKUP_DIR":/backup alpine tar czf /backup/ssl-certs.tar.gz -C /data .
    
    # Sauvegarde des configurations
    tar czf "$BACKUP_DIR/config.tar.gz" nginx/ traefik/ monitoring/ .env
    
    success "Sauvegarde créée dans $BACKUP_DIR"
}

# Affichage des informations de déploiement
show_info() {
    log "Informations de déploiement:"
    echo
    echo "🌐 Site web: https://$DOMAIN"
    echo "📊 Dashboard Traefik: https://traefik.$DOMAIN"
    echo "📈 Monitoring: https://monitoring.$DOMAIN"
    echo "📋 Dashboard Grafana: https://dashboard.$DOMAIN"
    echo
    echo "Environnement: $ENVIRONMENT"
    echo "Services actifs:"
    docker-compose ps
}

# Menu principal
main() {
    echo
    echo "🚀 Déploiement DATLIGENT Infrastructure"
    echo "======================================"
    echo
    
    check_requirements
    setup_environment
    
    if [ "$ENVIRONMENT" = "production" ]; then
        check_dns
        backup
    fi
    
    stop_services
    start_services
    health_check
    
    if [ "$ENVIRONMENT" = "production" ]; then
        cleanup
    fi
    
    show_info
    
    success "Déploiement terminé avec succès !"
}

# Gestion des signaux
trap 'error "Déploiement interrompu"; exit 1' INT TERM

# Exécution du script principal
main "$@"