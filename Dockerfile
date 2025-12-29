FROM python:3.11-slim

# Installer curl et autres dépendances système
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Installer uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# Ajouter uv au PATH de manière permanente (uv s'installe dans /root/.local/bin)
ENV PATH="/root/.local/bin:/root/.cargo/bin:$PATH"

# Vérifier que uv est accessible
RUN uv --version

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement le dossier agent (incluant les documents .md)
COPY agent/ /app/

# Vérifier que uv.lock existe avant d'installer
RUN test -f uv.lock || (echo "ERROR: uv.lock not found!" && exit 1)

# Installer les dépendances Python avec uv
RUN uv sync --frozen

# Exposer le port (Railway fournira le port via variable d'environnement)
EXPOSE 8000

# Commande de démarrage
CMD ["sh", "-c", "uv run uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]

