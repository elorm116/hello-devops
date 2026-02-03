import pytest
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

def test_home_page(client):
    """Test that home page loads"""
    response = client.get('/')
    assert response.status_code == 200
    assert b'Hello DevOps!' in response.data

def test_contains_hostname(client):
    """Test that page contains hostname"""
    response = client.get('/')
    assert b'Server:' in response.data

def test_contains_platform(client):
    """Test that page contains platform info"""
    response = client.get('/')
    assert b'Platform:' in response.data