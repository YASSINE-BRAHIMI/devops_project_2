import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_route(client):
    """Test the default route"""
    response = client.get('/')
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "Running on K3s"
    assert "message" in data

def test_health_route(client):
    """Test the health check route"""
    response = client.get('/health')
    assert response.status_code == 200
    data = response.get_json()
    assert data["status"] == "healthy"
