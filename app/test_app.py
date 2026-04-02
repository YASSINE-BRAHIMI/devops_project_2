# On importe pytest, le framework de tests Python
import pytest
# On importe notre application Flask pour la tester
from app import app

# @pytest.fixture = une fonction qui prépare l'environnement de test
@pytest.fixture
def client():
    # On active le mode test de Flask (désactive la gestion des erreurs pour voir les vraies)
    app.config['TESTING'] = True
    # On crée un client HTTP simulé pour envoyer des requêtes sans démarrer de vrai serveur
    with app.test_client() as client:
        # "yield" donne le client aux fonctions de test, puis nettoie après
        yield client

# Test 1 : on vérifie que la route "/" répond correctement
def test_home(client):
    # On envoie une requête GET sur "/"
    res = client.get('/')
    # On vérifie que le code HTTP retourné est 200 (= succès)
    assert res.status_code == 200
    # On vérifie que la réponse contient le mot "running"
    assert b'running' in res.data

# Test 2 : on vérifie que la route "/health" répond correctement
def test_health(client):
    # On envoie une requête GET sur "/health"
    res = client.get('/health')
    # On vérifie que le code HTTP est 200
    assert res.status_code == 200
    # On vérifie que la réponse contient le mot "healthy"
    assert b'healthy' in res.data