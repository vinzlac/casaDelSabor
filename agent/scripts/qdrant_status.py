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
import os
import sys
from pathlib import Path

# Ajouter le répertoire parent au path pour importer les modules
sys.path.insert(0, str(Path(__file__).parent.parent))

from config import Settings
from rag.vectorstore import get_qdrant_client


def print_section(title: str):
    """Affiche un titre de section."""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def check_cluster_status(client):
    """Vérifie le statut du cluster Qdrant."""
    try:
        print_section("📊 Statut du Cluster")
        
        # get_cluster_info() n'existe que pour les clusters Qdrant Cloud
        # Pour les instances locales, on essaie d'abord, sinon on affiche un message
        try:
            cluster_info = client.get_cluster_info()
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
        except AttributeError:
            # Instance locale (pas de cluster)
            print("ℹ️  Instance locale Qdrant (mode standalone)")
            print("   Les informations de cluster ne sont disponibles que pour Qdrant Cloud")
            print("   ✅ L'instance fonctionne correctement")
        except Exception as e:
            # Autre erreur (peut-être que l'API n'est pas disponible)
            print(f"ℹ️  Impossible de récupérer les infos de cluster: {e}")
            print("   (Normal pour une instance locale)")
        
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
        # Vérifier si c'est une erreur 404 (collection n'existe pas)
        error_str = str(e)
        if "404" in error_str or "doesn't exist" in error_str or "Not found" in error_str:
            print(f"ℹ️  La collection '{collection_name}' n'a pas encore été créée.")
            print(f"💡 Pour créer et indexer la collection, exécutez:")
            print(f"   cd agent && just ingest")
            return True  # Pas une vraie erreur, juste une info
        else:
            print(f"❌ Erreur lors de la récupération de la collection: {e}")
            return False


def check_connection(client, qdrant_url: str):
    """Vérifie la connexion au cluster."""
    try:
        print_section("🔌 Connexion")
        collections = client.get_collections()
        print(f"✅ Connexion réussie!")
        print(f"   URL: {qdrant_url}")
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
  %(prog)s                    # Affiche le statut de base (local par défaut)
  %(prog)s --collections      # Liste toutes les collections
  %(prog)s --collection casa_del_sabor  # Détails d'une collection
  %(prog)s --cluster          # Statut du cluster
  %(prog)s --all              # Tout afficher
  %(prog)s --env local        # Charge .env.local (défaut)
  %(prog)s --env prod         # Variables du shell uniquement (pas de fichier .env)
  %(prog)s --env prod --all
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
    
    parser.add_argument(
        "--env",
        type=str,
        choices=["local", "prod"],
        default="local",
        help="local = .env.local via Settings (défaut) ; prod = uniquement variables d'environnement exportées"
    )
    
    args = parser.parse_args()
    
    # Charger la configuration selon l'environnement spécifié
    try:
        repo_root = Path(__file__).resolve().parent.parent.parent
        if args.env == "local":
            settings = Settings()
            env_local = repo_root / ".env.local"
            print(f"🔧 Environnement: local (fichier: {env_local.name}, présent: {env_local.exists()})")
        else:
            # Prod : uniquement le shell / CI — ne pas lire .env ni .env.local
            settings = Settings(_env_file=None)
            print("🔧 Environnement: prod (variables d'environnement exportées uniquement)")
        print(f"📍 Qdrant URL: {settings.qdrant_url}\n")
    except Exception as e:
        print(f"❌ Erreur de configuration: {e}")
        print("💡 local : remplir .env.local à la racine du dépôt. prod : exporter QDRANT_URL, etc.")
        sys.exit(1)
    
    # Créer le client Qdrant avec les settings chargés
    try:
        # Créer le client manuellement avec les settings chargés
        from qdrant_client import QdrantClient
        
        client_kwargs = {"url": settings.qdrant_url}
        if settings.qdrant_api_key:
            client_kwargs["api_key"] = settings.qdrant_api_key
        
        client = QdrantClient(**client_kwargs)
    except Exception as e:
        print(f"❌ Erreur lors de la création du client Qdrant: {e}")
        sys.exit(1)
    
    # Vérifier la connexion
    if not check_connection(client, settings.qdrant_url):
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
            print(f"⚠️  Collection '{settings.qdrant_collection_name}' non trouvée")
            print(f"💡 Pour créer et indexer la collection, exécutez:")
            print(f"   cd agent && just ingest")
            print(f"💡 Ou utilisez --collections pour voir les collections disponibles")
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
