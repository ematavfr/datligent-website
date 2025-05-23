# Dockerfile pour le site web DATLIGENT
FROM nginx:alpine

# Métadonnées
LABEL maintainer="contact@datligent.fr"
LABEL description="Site web professionnel DATLIGENT - Expert DevOps & MLOps"
LABEL version="1.0"

# Installation des dépendances
RUN apk add --no-cache curl ca-certificates tzdata

# Configuration du fuseau horaire
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Copie du site web
COPY index.html /usr/share/nginx/html/

# Configuration NGINX personnalisée
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Création des répertoires nécessaires et permissions
RUN mkdir -p /var/log/nginx /var/cache/nginx && \
    chown -R nginx:nginx /usr/share/nginx/html /var/log/nginx /var/cache/nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Exposition du port
EXPOSE 80

# Commande par défaut
CMD ["nginx", "-g", "daemon off;"]