#!/usr/bin/env python3
"""Script de conversation interactive avec l'agent Casa del Sabor."""

import requests

API_URL = "http://localhost:8000"


def main():
    session_id = None
    print("🌮 Casa del Sabor - Chat (tapez 'quit' pour quitter)")
    print("=" * 50)
    
    while True:
        try:
            msg = input("\n👤 Vous: ")
            
            if msg.lower() in ["quit", "exit", "q"]:
                print("\n👋 ¡Hasta luego!")
                break
            
            if not msg.strip():
                continue
            
            payload = {"message": msg}
            if session_id:
                payload["session_id"] = session_id
            
            response = requests.post(f"{API_URL}/chat", json=payload)
            data = response.json()
            
            session_id = data.get("session_id")
            bot_response = data.get("response", "Erreur")
            
            print(f"\n🤖 Bot: {bot_response}")
            
        except KeyboardInterrupt:
            print("\n\n👋 ¡Hasta luego!")
            break
        except requests.exceptions.ConnectionError:
            print("\n❌ Erreur: Le serveur n'est pas accessible. Lancez 'just dev' d'abord.")
        except Exception as e:
            print(f"\n❌ Erreur: {e}")


if __name__ == "__main__":
    main()
