# On importe Flask pour créer l'application web et jsonify pour retourner du JSON
from flask import Flask, jsonify

# On crée l'application Flask, __name__ indique le nom du module courant
app = Flask(__name__)

# On définit la route "/" = la page d'accueil de l'application
@app.route('/')
def home():
    # On retourne un JSON avec un message et un statut (plus propre qu'un simple texte)
    return jsonify({"message": "Flask CI/CD app running!", "status": "ok"})

# On définit la route "/health" = utilisée par Kubernetes pour vérifier que l'app tourne
@app.route('/health')
def health():
    # Kubernetes appelle cette route régulièrement (livenessProbe dans deployment.yaml)
    return jsonify({"status": "healthy"})

# Ce bloc s'exécute seulement si on lance le fichier directement (pas en import)
if __name__ == '__main__':
    # On démarre le serveur sur toutes les interfaces réseau (0.0.0.0) port 5000
    # 0.0.0.0 = accessible depuis l'extérieur du conteneur Docker
    app.run(host='0.0.0.0', port=5000)