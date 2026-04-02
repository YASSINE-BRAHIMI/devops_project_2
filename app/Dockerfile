# On part de l'image officielle Python 3.9 en version "slim" (légère, sans outils inutiles)
FROM python:3.9-slim

# On définit /app comme répertoire de travail dans le conteneur
# Toutes les commandes suivantes s'exécutent depuis ce dossier
WORKDIR /app

# On copie SEULEMENT requirements.txt en premier (optimisation du cache Docker)
# Si le code change mais pas les dépendances, Docker réutilise le cache de pip install
COPY requirements.txt .

# On installe les dépendances Python listées dans requirements.txt
# --no-cache-dir = on ne garde pas le cache pip pour réduire la taille de l'image
RUN pip install --no-cache-dir -r requirements.txt

# On copie tout le reste du code source dans le conteneur
COPY . .

# On indique que le conteneur écoute sur le port 5000 (documentation, pas une règle)
EXPOSE 5000

# La commande exécutée quand le conteneur démarre
CMD ["python", "app.py"]