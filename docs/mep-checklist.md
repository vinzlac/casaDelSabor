# Checklist MEP k3s - Casa del Sabor

Checklist operationnelle pour securiser la mise en production de l'agent RAG.

## Image container (GHCR)

La CI pousse **`latest`**, **`main`** (branche `main`) et **`<sha>`**. Ne pas référencer un tag absent du registry (sinon `ErrImagePull` / Argo **Degraded**).

## 0) Contexte / prerequis

- [ ] `kubectl` pointe vers le bon cluster (`KUBECONFIG` k3s)
- [ ] Namespace cible connu (ex. `casadelsabor`)
- [ ] URL publique de l'API connue (Ingress)
- [ ] Virtual Key LiteLLM (`LLM_API_KEY`, prefixe `sk-...`) disponible
- [ ] Cle API agent (`API_KEY`) disponible pour `/ingest`, `/status`, `/upload`

Commandes utiles:

```bash
kubectl config current-context
kubectl get ns
```

## 1) Validation LiteLLM (avant deployer l'agent)

- [ ] `LLM_BASE_URL` termine par `/v1`
- [ ] `LLM_MODEL` existe dans `GET /v1/models`
- [ ] `EMBEDDING_MODEL` existe aussi dans `GET /v1/models`

```bash
export LLM_BASE_URL="https://llm.code-advisors.site/v1"   # ou homelab
export LLM_API_KEY="sk-..."

curl -sS "${LLM_BASE_URL%/}/models" \
  -H "Authorization: Bearer ${LLM_API_KEY}" | jq '.data[].id'
```

Test chat model:

```bash
curl -sS "${LLM_BASE_URL%/}/chat/completions" \
  -H "Authorization: Bearer ${LLM_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model":"mistral/mistral-tiny",
    "messages":[{"role":"user","content":"Ping"}],
    "temperature":0
  }' | jq .
```

Test embedding model:

```bash
curl -sS "${LLM_BASE_URL%/}/embeddings" \
  -H "Authorization: Bearer ${LLM_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "model":"mistral/mistral-embed",
    "input":"test"
  }' | jq '.data[0].embedding | length'
```

- [ ] Le test embeddings renvoie `1024` pour `mistral/mistral-embed`

## 2) Verification manifests k8s

- [ ] ConfigMap `casadelsabor-config` appliquee (base URL/modeles/Qdrant)
- [ ] Secret `casadelsabor-llm` present (`LLM_API_KEY`)
- [ ] Secret `casadelsabor-qdrant` present (`QDRANT_API_KEY` si necessaire)
- [ ] Secret `casadelsabor-api` present (`API_KEY`)

```bash
NS="casadelsabor"

kubectl -n "$NS" get configmap casadelsabor-config -o yaml
kubectl -n "$NS" get secret casadelsabor-llm
kubectl -n "$NS" get secret casadelsabor-qdrant
kubectl -n "$NS" get secret casadelsabor-api
```

## 3) Deploy / rollout

- [ ] Image correcte referencee dans le Deployment
- [ ] Rollout termine sans erreur
- [ ] Pod en `Running` + `Ready`

```bash
NS="casadelsabor"
DEPLOY="casadelsabor-api"

kubectl -n "$NS" apply -f kubernetes/
kubectl -n "$NS" rollout status deployment/"$DEPLOY" --timeout=180s
kubectl -n "$NS" get pods -o wide
```

## 4) Smoke tests post-deploiement

Variables:

```bash
API_BASE="https://<ton-domaine-api>"   # ex: https://api.casadelsabor.tld
AGENT_API_KEY="<api_key_agent>"
```

Health:

```bash
curl -sS "${API_BASE%/}/health" | jq .
```

Ingestion:

```bash
curl -sS -X POST "${API_BASE%/}/ingest" \
  -H "X-API-Key: ${AGENT_API_KEY}" \
  -H "Content-Type: application/json" | jq .
```

Status:

```bash
curl -sS "${API_BASE%/}/status" \
  -H "X-API-Key: ${AGENT_API_KEY}" | jq .
```

Chat:

```bash
curl -sS -X POST "${API_BASE%/}/chat" \
  -H "Content-Type: application/json" \
  -d '{"message":"De quoi parle l histoire de la Casa del Sabor ?"}' | jq .
```

- [ ] `/health` OK
- [ ] `/ingest` OK (pas d'erreur LiteLLM/Qdrant)
- [ ] `/status` montre la collection Qdrant
- [ ] `/chat` renvoie une reponse + `sources` non vide sur une question RAG

## 5) Cohérence embeddings / Qdrant

- [ ] Si changement de `EMBEDDING_MODEL`, la dimension est compatible avec la collection existante
- [ ] En cas de changement de dimension (ex. 1536 -> 1024), collection recreatee puis reingestion

## 6) Observabilite / securite

- [ ] Logs pods sans erreurs recurrentes
- [ ] `AGENT_DEBUG=false` en prod
- [ ] Endpoints sensibles testes avec et sans `X-API-Key`
- [ ] Aucun secret en clair committe

```bash
kubectl -n "$NS" logs deployment/"$DEPLOY" --tail=200
```

## 7) Rollback

- [ ] Tag precedent connu
- [ ] Commande rollback validee
- [ ] Procedure reindexation documentee

```bash
kubectl -n "$NS" rollout history deployment/"$DEPLOY"
kubectl -n "$NS" rollout undo deployment/"$DEPLOY"
```

---

## Valeurs recommandees (homelab actuel)

- `LLM_MODEL`: `mistral/mistral-tiny` (si present dans `/v1/models`)
- `EMBEDDING_MODEL`: `mistral/mistral-embed` (dimension 1024)

