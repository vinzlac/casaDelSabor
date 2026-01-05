"""
Script pour contrôler un service Railway via l'API GraphQL.

Usage:
    python railway_control.py --action stop --api-key YOUR_API_KEY
    python railway_control.py --action start --api-key YOUR_API_KEY
    python railway_control.py --action status --api-key YOUR_API_KEY
"""

import argparse
import requests
import json
import sys
from typing import Optional


RAILWAY_API_URL = "https://backboard.railway.app/graphql/v2"


def get_project_id(api_key: str, project_name: str = "sunny-empathy") -> Optional[str]:
    """Récupère l'ID du projet Railway."""
    query = """
    query {
        projects {
            id
            name
        }
    }
    """
    
    response = requests.post(
        RAILWAY_API_URL,
        json={"query": query},
        headers={"Authorization": f"Bearer {api_key}"}
    )
    
    if response.status_code != 200:
        print(f"Erreur: {response.status_code} - {response.text}")
        return None
    
    data = response.json()
    if "errors" in data:
        print(f"Erreur GraphQL: {data['errors']}")
        return None
    
    projects = data.get("data", {}).get("projects", [])
    for project in projects:
        if project["name"] == project_name or project["id"] == project_name:
            return project["id"]
    
    print(f"Projet '{project_name}' non trouvé. Projets disponibles:")
    for project in projects:
        print(f"  - {project['name']} (ID: {project['id']})")
    return None


def get_service_id(api_key: str, project_id: str, service_name: str = "casaDelSabor") -> Optional[str]:
    """Récupère l'ID du service Railway."""
    query = """
    query($projectId: String!) {
        project(id: $projectId) {
            services {
                id
                name
            }
        }
    }
    """
    
    response = requests.post(
        RAILWAY_API_URL,
        json={"query": query, "variables": {"projectId": project_id}},
        headers={"Authorization": f"Bearer {api_key}"}
    )
    
    if response.status_code != 200:
        print(f"Erreur: {response.status_code} - {response.text}")
        return None
    
    data = response.json()
    if "errors" in data:
        print(f"Erreur GraphQL: {data['errors']}")
        return None
    
    services = data.get("data", {}).get("project", {}).get("services", [])
    for service in services:
        if service["name"] == service_name or service["id"] == service_name:
            return service["id"]
    
    print(f"Service '{service_name}' non trouvé. Services disponibles:")
    for service in services:
        print(f"  - {service['name']} (ID: {service['id']})")
    return None


def get_service_status(api_key: str, service_id: str) -> dict:
    """Récupère le statut d'un service."""
    query = """
    query($serviceId: String!) {
        service(id: $serviceId) {
            id
            name
            status
            deployments {
                id
                status
                createdAt
            }
        }
    }
    """
    
    response = requests.post(
        RAILWAY_API_URL,
        json={"query": query, "variables": {"serviceId": service_id}},
        headers={"Authorization": f"Bearer {api_key}"}
    )
    
    if response.status_code != 200:
        return {"error": f"{response.status_code} - {response.text}"}
    
    data = response.json()
    if "errors" in data:
        return {"error": data["errors"]}
    
    return data.get("data", {}).get("service", {})


def stop_service(api_key: str, service_id: str) -> bool:
    """
    Arrête un service Railway.
    
    Note: Railway ne permet pas d'arrêter directement un service via l'API.
    Les options disponibles sont:
    1. Supprimer le service (serviceDelete) - permanent
    2. Mettre à jour les variables d'environnement pour désactiver le service
    3. Utiliser l'interface web pour suspendre le service
    
    Cette fonction affiche les informations nécessaires.
    """
    print("⚠️  Railway ne permet pas d'arrêter directement un service via l'API GraphQL.")
    print("\nOptions disponibles:")
    print("1. Supprimer le service (permanent):")
    print("   mutation { serviceDelete(id: \"<service_id>\") }")
    print("\n2. Suspendre via l'interface web Railway")
    print("\n3. Modifier les variables d'environnement pour désactiver le service")
    
    status = get_service_status(api_key, service_id)
    if "error" not in status:
        print(f"\nStatut actuel du service:")
        print(json.dumps(status, indent=2))
    
    return False


def main():
    parser = argparse.ArgumentParser(description="Contrôler un service Railway via l'API")
    parser.add_argument("--action", choices=["stop", "start", "status"], required=True,
                       help="Action à effectuer")
    parser.add_argument("--api-key", required=True, help="Clé API Railway")
    parser.add_argument("--project", default="sunny-empathy", help="Nom ou ID du projet")
    parser.add_argument("--service", default="casaDelSabor", help="Nom ou ID du service")
    
    args = parser.parse_args()
    
    # Récupérer l'ID du projet
    project_id = get_project_id(args.api_key, args.project)
    if not project_id:
        sys.exit(1)
    
    print(f"✅ Projet trouvé: {project_id}")
    
    # Récupérer l'ID du service
    service_id = get_service_id(args.api_key, project_id, args.service)
    if not service_id:
        sys.exit(1)
    
    print(f"✅ Service trouvé: {service_id}")
    
    # Exécuter l'action
    if args.action == "status":
        status = get_service_status(args.api_key, service_id)
        if "error" in status:
            print(f"❌ Erreur: {status['error']}")
            sys.exit(1)
        print("\n📊 Statut du service:")
        print(json.dumps(status, indent=2))
    
    elif args.action == "stop":
        stop_service(args.api_key, service_id)
    
    elif args.action == "start":
        print("ℹ️  Pour démarrer un service, utilisez l'interface Railway ou redéployez via git push.")


if __name__ == "__main__":
    main()

