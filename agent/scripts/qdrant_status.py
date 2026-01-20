#!/usr/bin/env python3
"""
Script CLI pour vérifier le statut du cluster Qdrant.

Usage:
    python agent/scripts/qdrant_status.py
    python agent/scripts/qdrant_status.py --collections
    python agent/scripts/qdrant_status.py --collection casa_del_sabor
    python agent/scripts/qdrant_status.py --cluster
"""

import argparse
import json
import sys
from pathlib import Path

# Ajouter le répertoire parent au path pour importer les modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from config import get_settings
from rag.vectorstore import get_qdrant_client


def print_section(title: str):
    """Affiche un titre de section."""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def check_cluster_status(client):
    """Vérifie le statut du cluster Qdrant."""
    try:
        cluster_info = client.get_cluster_info()
        print_section("📊 Statut du Cluster")
        
        print(f"État: {cluster_info.status}")
        print(f"Consensus: {cluster_info.consensus_thread_status}")
        
        if hasattr(cluster_info, 'peers'):
            print(f"\nPairs (Peers): {len(cluster_info.peers)}")
            for peer_id, peer_info in cluster_info.peers.items():
                print(f"  - Peer {peer_id}: {peer_info}")
        
        if hasattr(cluster_info, 'raft_info'):
            print(f"\nRaft Info:")
            print(f"  - Term: {cluster_info.raft_info.term}")
            print(f"  - Commit: {cluster_info.raft_info.commit}")
            print(f"  - Pending operations: {cluster_info.raft_info.pending_operations}")
        
        return True
    except Exception as e:
        print(f"❌ Erreur lors de la récupération du statut du cluster: {e}")
        return False


def list_collections(client):
    """Liste toutes les collections."""
    try:
        collections = client.get_collections()
        print_section("📚 Collections")
        
        if not collections.collections:
            print("Aucune collection trouvée.")
            return
        
        for collection in collections.collections:
            print(f"\n📦 {collection.name}")
            try:
                info = client.get_collection(collection.name)
                print(f"   Points: {info.points_count:,}")
                print(f"   Statut: {info.status.value}")
                if hasattr(info.config, 'params'):
                    params = info.config.params
                    if hasattr(params, 'vectors'):
                        if isinstance(params.vectors, dict):
                            for vec_name, vec_config in params.vectors.items():
                                print(f"   Vecteurs '{vec_name}': {vec_config.size} dimensions")
                        else:
                            print(f"   Vecteurs: {params.vectors.size} dimensions")
            except Exception as e:
                print(f"   ⚠️  Erreur lors de la récupération des infos: {e}")
        
        return True
    except Exception as e:
        print(f"❌ Erreur lors de la récupération des collections: {e}")
        return False


def show_collection_details(client, collection_name: str):
    """Affiche les détails d'une collection spécifique."""
    try:
        print_section(f"📦 Collection: {collection_name}")
        
        info = client.get_collection(collection_name)
        
        print(f"Nom: {info.name}")
        print(f"Points: {info.points_count:,}")
        print(f"Statut: {info.status.value}")
        
        if hasattr(info, 'config'):
            config = info.config
            print(f"\nConfiguration:")
            if hasattr(config, 'params'):
                params = config.params
                print(f"  Distance: {params.distance}")
                if hasattr(params, 'vectors'):
                    if isinstance(params.vectors, dict):
                        for vec_name, vec_config in params.vectors.items():
                            print(f"  Vecteurs '{vec_name}':")
                            print(f"    - Taille: {vec_config.size}")
                            print(f"    - Distance: {vec_config.distance}")
                    else:
                        print(f"  Vecteurs:")
                        print(f"    - Taille: {params.vectors.size}")
                        print(f"    - Distance: {params.vectors.distance}")
        
        if hasattr(info, 'optimizer_status'):
            print(f"\nOptimiseur: {info.optimizer_status}")
        
        if hasattr(info, 'indexed_vectors_count'):
            print(f"Vecteurs indexés: {info.indexed_vectors_count:,}")
        
        return True
    except Exception as e:
        print(f"❌ Erreur lors de la récupération de la collection: {e}")
        return False


def check_connection(client):
    """Vérifie la connexion au cluster."""
    try:
        print_section("🔌 Connexion")
        collections = client.get_collections()
        print(f"✅ Connexion réussie!")
        print(f"   URL: {client._client.url}")
        print(f"   Collections disponibles: {len(collections.collections)}")
        return True
    except Exception as e:
        print(f"❌ Échec de la connexion: {e}")
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Vérifier le statut du cluster Qdrant",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Exemples:
  %(prog)s                    # Affiche le statut de base
  %(prog)s --collections      # Liste toutes les collections
  %(prog)s --collection casa_del_sabor  # Détails d'une collection
  %(prog)s --cluster          # Statut du cluster
  %(prog)s --all              # Tout afficher
        """
    )
    
    parser.add_argument(
        "--collections",
        action="store_true",
        help="Lister toutes les collections"
    )
    
    parser.add_argument(
        "--collection",
        type=str,
        help="Afficher les détails d'une collection spécifique"
    )
    
    parser.add_argument(
        "--cluster",
        action="store_true",
        help="Afficher le statut du cluster"
    )
    
    parser.add_argument(
        "--all",
        action="store_true",
        help="Afficher toutes les informations"
    )
    
    parser.add_argument(
        "--json",
        action="store_true",
        help="Sortie au format JSON"
    )
    
    args = parser.parse_args()
    
    # Charger la configuration
    try:
        settings = get_settings()
    except Exception as e:
        print(f"❌ Erreur de configuration: {e}")
        print("💡 Assurez-vous que les variables d'environnement sont définies dans .env")
        sys.exit(1)
    
    # Créer le client Qdrant
    try:
        client = get_qdrant_client()
    except Exception as e:
        print(f"❌ Erreur lors de la création du client Qdrant: {e}")
        sys.exit(1)
    
    # Vérifier la connexion
    if not check_connection(client):
        sys.exit(1)
    
    # Si --all, afficher tout
    if args.all:
        args.collections = True
        args.cluster = True
        if not args.collection:
            args.collection = settings.qdrant_collection_name
    
    # Afficher les informations demandées
    success = True
    
    if args.collections:
        success = list_collections(client) and success
    
    if args.collection:
        success = show_collection_details(client, args.collection) and success
    
    if args.cluster:
        success = check_cluster_status(client) and success
    
    # Si aucune option spécifique, afficher le résumé par défaut
    if not (args.collections or args.collection or args.cluster):
        print_section("📊 Résumé")
        try:
            info = client.get_collection(settings.qdrant_collection_name)
            print(f"Collection principale: {settings.qdrant_collection_name}")
            print(f"Points: {info.points_count:,}")
            print(f"Statut: {info.status.value}")
            print(f"\n💡 Utilisez --help pour plus d'options")
        except Exception as e:
            print(f"⚠️  Collection '{settings.qdrant_collection_name}' non trouvée: {e}")
            print(f"💡 Utilisez --collections pour voir les collections disponibles")
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
