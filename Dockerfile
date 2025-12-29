FROM python:3.11-slim

# Installer curl et autres dépendances système
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Installer uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Définir le répertoire de travail
WORKDIR /app

# Copier uniquement le dossier agent
COPY agent/ /app/

# Installer les dépendances Python avec uv
RUN uv sync --frozen

# Exposer le port (Railway fournira le port via variable d'environnement)
EXPOSE 8000

# Commande de démarrage
CMD ["sh", "-c", "uv run uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]

