# Plan d’implémentation — dépôt **casaDelSabor** (Railway + k3s)

> **Usage :** copier ce fichier dans le dépôt [vinzlac/casaDelSabor](https://github.com/vinzlac/casaDelSabor) (ex. `docs/PLAN_K3S_RAILWAY.md`) pour guider une IA ou une série de PRs.  
> **Côté cluster / scripts :** plan jumeau dans le repo **k3s-homelab** : `docs/plan-implement-homelab-casadelsabor-k3s.md` (sur GitHub : même chemin dans `vinzlac/k3s-homelab` ou équivalent).  
> **Après copie dans casaDelSabor :** les liens Markdown relatifs vers `plan-implement-homelab-…` ou `plan-rag-…` ne fonctionneront plus ; remplacer par une URL absolue vers le dépôt homelab si besoin.

## Objectif

Faire **cohabiter** dans le **même repo** :

1. **Déploiement actuel** : Railway (agent FastAPI) + **Qdrant Cloud** + front Vercel (si applicable).
2. **Nouveau déploiement homelab** : image **GHCR** déployée sur **k3s** via **Argo CD** (manifests gérés depuis le repo **k3s-homelab** ou, en variante, sous `kubernetes/` dans ce repo), avec **Qdrant in-cluster** (détails côté homelab).

Un **push** sur la branche suivie peut déclencher **en parallèle** : build Railway (inchangé) + **GitHub Actions** → push image GHCR → Argo sync (côté homelab).

## CI/CD GitHub Actions + Argo CD : pas à réinventer à la main

Le flux **build → GHCR → déploiement k3s** doit réutiliser **les mêmes artefacts** que ceux générés par le homelab pour une app externe standard :

- Dans **k3s-homelab**, le script **`scripts/create-app.sh`** matérialise le squelette depuis le dossier **`templates/external-app-repo/`** (à la racine du repo homelab) : notamment **`.github/workflows/build-push.yml`** (BuildKit in-cluster + push GHCR + option GitOps sur `kubernetes/deployment.yaml`), **`kubernetes/`** (Deployment, Service, Ingress, exemples de secrets), **`scripts/setup-github-actions.sh`** (secret `BUILDKIT_HOST`, `gh`, etc.).
- Pour **casaDelSabor** (dépôt déjà existant), l’objectif côté homelab est d’**étendre** `create-app.sh` (ou un script voisin) pour **injecter ces mêmes fichiers** dans le repo app **sans** recréer tout le projet — puis l’opérateur lance **`create-cicd.sh <id>`** depuis la racine **k3s-homelab** (runner ARC, `kubectl apply` Application Argo, `ghcr-pull`, hosts, CoreDNS), comme pour les autres apps du registry.

**Conséquence pour ce dépôt (implémentation / PR)** :

- Priorité : **fusionner** dans casaDelSabor le workflow et le dossier `kubernetes/` **alignés sur le template** homelab (chemins, noms d’image `ghcr.io/<owner>/<repo>:…`, `paths-ignore`, secret `BUILDKIT_HOST`), plutôt que d’écrire un workflow ad hoc « docker build sur ubuntu-latest » — sauf décision explicite de diverger du BuildKit homelab.
- L’**Application Argo CD** et l’entrée **`applications/registry.yaml`** restent dans **k3s-homelab** ; ce repo contient le **code**, l’**image** (via CI) et, selon l’option GitOps, les manifests sous `kubernetes/` mis à jour par le bot CI.

---

## Phase A — Configuration : un seul contrat (variables d’environnement)

### A.1 Inventaire

- Lister **toutes** les valeurs aujourd’hui dans : `.env` / `.env.local`, `agent/config.py`, et tout **hardcodé** dans LangChain (URL LLM, noms de modèles, collection Qdrant, timeouts).
- Produit attendu : tableau « nom de variable → usage → secret oui/non → défaut local dev ».

### A.2 Module `settings` (recommandé : `pydantic-settings`)

- Créer un module unique (ex. `agent/settings.py`) qui charge **uniquement** depuis l’environnement (et optionnellement `.env` en dev via `env_file`, jamais commité).
- **`agent/config.py`** : soit supprimé au profit de `settings`, soit réduit à un **re-export** déprécié pour ne pas casser les imports temporairement.
- **Interdit** dans le code métier : clés API, URLs de prod, noms de modèles en dur (sauf défauts **non sensibles** explicitement acceptés).

### A.3 Variables à prévoir (à ajuster selon l’état réel du code)

| Catégorie | Exemples de noms (à unifier) | Secret ? |
|-----------|------------------------------|----------|
| LLM | `LLM_BASE_URL`, `LLM_API_KEY`, `LLM_MODEL`, `LLM_TEMPERATURE` | clé oui |
| Embeddings | `EMBEDDING_MODEL`, même base URL ou variables Mistral dédiées | clé si API payante |
| Qdrant | `QDRANT_URL`, `QDRANT_API_KEY`, `QDRANT_COLLECTION_NAME` | clé si activée |
| Agent | `API_KEY` (auth `/ingest` ou admin) | oui |
| Mistral legacy | `MISTRAL_API_KEY` — à mapper vers `LLM_*` si unification OpenAI-compatible | oui |

- **Bascule LiteLLM (homelab)** : exposer `LLM_BASE_URL` (ex. `http://llm.homelab/v1`) + modèle type alias LiteLLM ; le client LangChain doit utiliser le mode **OpenAI-compatible** (`ChatOpenAI` + `base_url`) pour éviter deux code paths Mistral vs OpenAI si possible.

### A.4 Documentation

- Mettre à jour **`agent/.env.example`** (ou racine si partagé) : **toutes** les clés, commentaires, valeurs d’exemple **sans secrets**.
- Mentionner dans le README : **Railway** et **k8s** utilisent les **mêmes noms** ; seules les **valeurs** changent (`QDRANT_URL` Cloud vs URL Service cluster — voir plan homelab).

### Critères de succès A

- `grep` dans `agent/` : plus de clés ni d’URL sensibles hors `settings` / chargement env.
- Démarrage local inchangé : `just dev` avec `.env` local.
- Railway : variables renommées si besoin, **documentées** dans README ou doc Railway.

---

## Phase B — CI/CD GitHub Actions (image GHCR pour k3s)

### B.1 Alignement sur le template `create-app`

- Reprendre **`.github/workflows/build-push.yml`** du template homelab (substitution `__RUNS_ON_SCALE_SET__` → label ARC, ex. `arc-runner-<id>-k3s-geekom-as6`, comme pour les autres apps).
- Vérifier que le **`Dockerfile` racine** et le **contexte** correspondent à ce que le workflow attend (`context: .`, `file: ./Dockerfile`).
- Après copie des fichiers dans ce repo : exécuter **`./scripts/setup-github-actions.sh`** (fourni par le même template) **depuis la racine de casaDelSabor** pour enregistrer le secret repo **`BUILDKIT_HOST`** (`tcp://buildkitd.cicd.svc.cluster.local:1234` par défaut homelab) — référence homelab : `templates/external-app-repo/scripts/setup-github-actions.sh` ; guide : `docs/guide-add-external-app-k3s.md` dans **k3s-homelab**.

### B.2 GitOps image (option template)

- Si `kubernetes/deployment.yaml` est présent dans ce repo, le workflow peut **mettre à jour** la ligne `image:` avec le SHA du commit (évite de pinner la tag à la main). Sinon Argo peut utiliser une image taguée `main` selon la stratégie retenue.

### B.3 Runners

- **`runs-on`** : self-hosted **ARC** (homelab), pas `ubuntu-latest`, pour parler au BuildKit du cluster — cohérent avec `create-cicd.sh`.

### Critères de succès B

- Workflow vert ; image **`ghcr.io/<owner>/casadelsabor`** (nom dérivé du repo GitHub, minuscules) visible sur GHCR ; pas de secret sensible dans le YAML (uniquement secrets GitHub : `BUILDKIT_HOST`, `GITHUB_TOKEN`).

---

## Phase C — Ne pas casser Railway / Vercel

### C.1 Railway

- Conserver `railway.toml` / Dockerfile / Nixpacks tels quels sauf si refactor nécessaire.
- Vérifier que les **nouveaux noms** de variables (Phase A) sont renseignés dans le dashboard Railway.

### C.2 Frontend (Next.js)

- `AGENT_URL` (ou équivalent) : inchangé conceptuellement ; documenter les **deux** URLs possibles (Railway public vs Ingress homelab) pour les tests.

### Critères de succès C

- Déploiement Railway existant toujours fonctionnel après merge des phases A–B.

---

## Phase D — Manifests Kubernetes (selon choix GitOps)

**Deux options** (décision avec le repo homelab) :

1. **Manifests dans k3s-homelab** (aligné ADR apps externes) : ce repo ne contient que l’**image** + la doc ; Argo pointe vers `k3s-homelab`.
2. **Dossier `kubernetes/` dans casaDelSabor** : Argo peut pointer sur ce repo ; le homelab ne duplique que l’Application Argo + meta — c’est le modèle **template `create-app`** (Deployment + Service + Ingress dans le repo app).

Dans les deux cas, prévoir pour l’agent :

- `Deployment` (image GHCR, `imagePullSecrets` si privé) ;
- `Service` ;
- `Ingress` Traefik (`web` + `websecure`) si exposition `*.homelab` ;
- **ConfigMap** + **Secret** (détail ci-dessous).

### D.1 ConfigMap Kubernetes (configuration non secrète)

Ressource dédiée (ex. `casadelsabor-config`) : toute variable **safe** à versionner en clair dans le git du homelab (ou en exemple dans ce repo).

| Variable (exemples) | Rôle |
|---------------------|------|
| `QDRANT_URL` | URL du service Qdrant **in-cluster** (ex. `http://qdrant.<namespace>.svc.cluster.local:6333`) — non secret en général |
| `QDRANT_COLLECTION_NAME` | Nom de collection |
| `LLM_MODEL` / `EMBEDDING_MODEL` | Identifiants de modèles (non secrets) |
| `LLM_BASE_URL` | Si pointage interne LiteLLM (`http://llm.homelab/...`) — souvent non secret en LAN |
| `LLM_TEMPERATURE`, timeouts, flags debug | Selon `settings` |

**Fichiers** : commiter un **`configmap.yaml`** ou un **`*-configmap.yaml.example`** avec des valeurs d’exemple ; l’opérateur duplique/adapte pour la prod. Le **Deployment** référence la ConfigMap via `envFrom` ou `valueFrom` pour chaque clé.

```yaml
# Exemple de principe (non exhaustif) — le vrai fichier suit le template homelab / conventions du namespace
apiVersion: v1
kind: ConfigMap
metadata:
  name: casadelsabor-config
data:
  QDRANT_URL: "http://qdrant.qdrant.svc.cluster.local:6333"
  QDRANT_COLLECTION_NAME: "casadelsabor"
  LLM_BASE_URL: "http://llm.llm.svc.cluster.local/v1"
  LLM_MODEL: "openai/gpt-4o-mini"
```

Les **noms de clés** doivent **coller** à ceux lus par `agent/settings.py` (Phase A).

### D.2 Secret Kubernetes (données sensibles)

**Jamais** de valeurs réelles dans git (sauf chiffré via Sealed Secrets). Dans ce dépôt, les clés sont **réparties en trois Secrets** (blast radius / rotation indépendante) :

| Secret (ressource) | Clé(s) typique(s) | Rôle |
|--------------------|-------------------|------|
| `casadelsabor-llm` | `LLM_API_KEY` | Fournisseur LLM |
| `casadelsabor-qdrant` | `QDRANT_API_KEY` | Qdrant (souvent vide en local) |
| `casadelsabor-api` | `API_KEY` | Auth admin agent (`/ingest`, etc.) |

**Fichiers** : gabarit `kubernetes/casadelsabor-secret.yaml.example` ; en prod, **trois** `SealedSecret` : `casadelsabor-llm.sealed.yaml`, `casadelsabor-qdrant.sealed.yaml`, `casadelsabor-api.sealed.yaml`.

Le **Deployment** référence chaque Secret via `valueFrom.secretKeyRef` (pas un seul `secretRef` tout-en-un) :

```yaml
env:
  - name: LLM_API_KEY
    valueFrom: { secretKeyRef: { name: casadelsabor-llm, key: LLM_API_KEY } }
  - name: QDRANT_API_KEY
    valueFrom:
      secretKeyRef: { name: casadelsabor-qdrant, key: QDRANT_API_KEY, optional: true }
  - name: API_KEY
    valueFrom:
      secretKeyRef: { name: casadelsabor-api, key: API_KEY, optional: true }
envFrom:
  - configMapRef: { name: casadelsabor-config }
```

#### Sealed Secrets (recommandé en k3s / GitOps)

Pour **versionner** des secrets dans Git **sans** y mettre de clés en clair, utiliser **Sealed Secrets** (opérateur Bitnami / `SealedSecret`). Chaque manifest contient des **`encryptedData`** par clé ; le contrôleur produit les **Secret** `casadelsabor-llm`, `casadelsabor-qdrant`, `casadelsabor-api`.

- **Exemples dans ce dépôt** : `kubernetes/casadelsabor-llm.sealed.yaml`, `kubernetes/casadelsabor-qdrant.sealed.yaml`, `kubernetes/casadelsabor-api.sealed.yaml`.
- **Rotation / mise à jour** : recréer le Secret ciblé puis `kubeseal -o yaml` (ou équivalent homelab).

### D.3 Cohérence avec Railway

Les **mêmes noms** de variables qu’en Phase A : Railway Dashboard = équivalent « plat » de ConfigMap + Secret ; pas de divergence de noms entre plateformes.

### Post-déploiement

- **Ingestion** : appeler `POST /ingest` une fois les pods up (Job Kubernetes, script manuel, ou init container si pertinent — éviter double ingestion au scale-up sans garde).

---

## Phase E — Tests et garde-fous

- Tests unitaires légers sur `settings` (variables manquantes → erreur claire).
- Healthcheck déjà exposé : s’assurer qu’il ne log pas de secrets.
- `.gitignore` : `.env`, `.env.local`, tout fichier de secrets.

---

## État d’avancement (dépôt)

- **Phase A** : `agent/settings.py` (pydantic-settings, `LLM_*` + alias `MISTRAL_*`, `LLM_BASE_URL` → `ChatOpenAI`) ; `agent/config.py` réexporte `get_settings` / `Settings`. `agent/.env.example` et `rag/chain.py` / `rag/embeddings.py` à jour.
- **Phase B** : `.github/workflows/build-push.yml` (GHCR via `docker/build-push-action`, image en minuscules). Pour ARC + BuildKit homelab, remplacer par le template `external-app-repo` (secret `BUILDKIT_HOST`).
- **Phase D** : `kubernetes/` — ConfigMap, gabarit `casadelsabor-secret.yaml.example`, **Sealed Secrets** (`casadelsabor-llm`, `casadelsabor-qdrant`, `casadelsabor-api`), Deployment / Service / Ingress selon les fichiers présents.
- **Phase E** : `agent/tests/test_settings.py` + `pythonpath` pytest dans `agent/pyproject.toml`.

---

## Ordre d’exécution recommandé

1. **Phase A** (settings + refacto imports LangChain / Qdrant / LLM).
2. **Phase B** : intégrer le **workflow + scripts du template** `create-app` ; configurer secrets GitHub ; valider build GHCR.
3. Valider **C** sur Railway + dev local.
4. **Phase D** : manifests (y compris **ConfigMap / Secret** et câblage `envFrom`) ; côté homelab : **Argo + `create-cicd.sh`** ; sync.
5. **Phase E** en continu.

---

## Références externes

- Repo **k3s-homelab** : `scripts/create-app.sh`, `scripts/create-cicd.sh`, `templates/external-app-repo/` (workflow, `kubernetes/`, `scripts/setup-github-actions.sh`), `docs/guide-add-external-app-k3s.md`.
- Plan cluster / Qdrant / mode repo existant : `docs/plan-implement-homelab-casadelsabor-k3s.md`.
- Plan RAG / OpenSearch homelab (optionnel si tu restes sur Qdrant) : `docs/plan-rag-casadelsabor-opensearch.md`.
