# casadelsabor

Application déployée sur le homelab k3s via **Argo CD** (dépôt **`vinzlac/k3s-homelab`**, ressource Application `casadelsabor`).

## Stack

**Mode `create-app.sh --existing-repo`** : aucun fichier du template `external-app-repo` n'a été copié dans le clone. Ajoute **`.github/workflows/build-push.yml`**, **`kubernetes/`**, **`scripts/setup-github-actions.sh`** depuis `k3s-homelab/templates/external-app-repo/`, ou lance **`./scripts/sync-app.sh <id-argocd>`** depuis le repo homelab une fois le **meta** enregistré (`skeletonPath` = ce clone). Puis **`./scripts/setup-github-actions.sh`** dans le dépôt app (secret **`BUILDKIT_HOST`**) et **`./scripts/create-cicd.sh <id>`** sur le homelab.



*(Identifiant stack homelab : **`existing-repo`** — `templates/app-stacks/stacks.yaml` dans le repo k3s-homelab.)*

La vérité opérationnelle (ports, UID, probes) suit **`Dockerfile`** et **`kubernetes/deployment.yaml`** dans ce dépôt.

## GitHub Actions — faire tourner la CI (BuildKit + ARC)

Le build ne s’exécute **pas** sur les runners hébergés par GitHub : il tourne sur un **runner in-cluster** (Actions Runner Controller, **scale set** **`arc-runner-casadelsabor`**) qui peut joindre **BuildKit** en `ClusterIP`. Voir [install-arc-k3s](https://github.com/vinzlac/k3s-homelab/blob/main/docs/install-arc-k3s.md) dans **k3s-homelab**.

### Secret obligatoire : `BUILDKIT_HOST`

| Secret | Valeur |
|--------|--------|
| **`BUILDKIT_HOST`** | `tcp://buildkitd.cicd.svc.cluster.local:1234` |

Sans lui, le workflow **`.github/workflows/build-push.yml`** ne peut pas contacter BuildKit → échec / timeout sur les étapes **buildx** ou build.

### Quand et comment le configurer

1. Sur ta machine, à la **racine de ce repo** :

   ```bash
   ./scripts/setup-github-actions.sh
   ```

   Le script peut **créer le dépôt GitHub** (`gh repo create`) si besoin — tu choisis **public** ou **privé** — puis **`git init`** / **commit initial** / **push** si nécessaire, et enfin enregistre **`BUILDKIT_HOST`** (le dépôt distant doit exister avant le secret ; le script enchaîne dans le bon ordre). **`brew install gh`** si besoin ; **`gh auth login`** si aucune session.

2. Vérifie dans GitHub : **Settings → Secrets and variables → Actions** que **`BUILDKIT_HOST`** est présent.

Détails (rôle du script, prérequis, ré-exécution) : **[`scripts/README.md`](scripts/README.md)**.

### Mise à jour du squelette / de la doc (depuis k3s-homelab)

Le dépôt **[k3s-homelab](https://github.com/vinzlac/k3s-homelab)** contient le template commun (`templates/external-app-repo/`) et les stacks (`templates/app-stacks/`). Pour **ajouter** les fichiers manquants et **rafraîchir** le **README** racine et **`scripts/README.md`** sans toucher au reste :

```bash
# depuis le clone k3s-homelab
./scripts/sync-app.sh casadelsabor
```

(`casadelsabor` = id dans **`applications/registry.yaml`**, souvent le nom de l’Application Argo.)

## Image

- **`ghcr.io/vinzlac/casadelsabor`** — tags **`:<sha>`** et **`:main`**.
- Après chaque build, le workflow commit **`kubernetes/deployment.yaml`** avec le tag **SHA** (ne relance pas le workflow grâce à `paths-ignore: kubernetes/**`).

## Cluster

- **Namespace** : `casadelsabor`
- **Ingress** : `http://casadelsabor.homelab` (ajoute l’host dans `scripts/add-hosts.sh` + CoreDNS si besoin, comme pour les autres `*.homelab`)

### Secret pull GHCR (package privé)

```bash
# depuis la machine avec kubectl configuré
kubectl create secret docker-registry ghcr-pull \
  --namespace=casadelsabor \
  --docker-server=ghcr.io \
  --docker-username=TON_LOGIN_GITHUB \
  --docker-password=TON_PAT_READ_PACKAGES \
  --dry-run=client -o yaml | kubectl apply -f -
```

Ou depuis **k3s-homelab** : `GHCR_PULL_NAMESPACE=casadelsabor ./scripts/create-ghcr-pull-secret.sh` (utilise `GHCR_USERNAME` / `GHCR_TOKEN` dans `.env`).

## Développement local

Les commandes dépendent de la stack (voir `package.json`, `requirements.txt`, `Cargo.toml`, etc. à la racine).

## Contexte homelab / CI (pour toi ou un assistant IA)

À la racine : **`install-k3s.md`** — généré par **`k3s-homelab/scripts/create-app.sh`** (template **`templates/external-app-repo/install-k3s.md`**, rendu via **`render-app-install-k3s-doc.sh`**). Il résume k3s, **geekom-as6**, GitHub Actions, Argo CD, GHCR. Tu peux le **régénérer** depuis le repo homelab : **`./scripts/update-app.sh <nom-app-argocd>`**.

## Structure (indicative)

```
.
├── install-k3s.md
├── Dockerfile
├── kubernetes/
├── scripts/
└── .github/workflows/
```
