# Projet 6 – Déploiement Frontend & Backend avec Docker

Ce dépôt contient l’ensemble des livrables pour le projet 6 : l’application Angular (frontend) et l’application Java Spring Boot (backend), toutes deux prêtes à être conteneurisées et orchestrées avec Docker.


## Sommaire

- [Structure du dépôt](#structure-du-d%C3%A9p%C3%B4t)
- [Lancement rapide (global)](#lancement-rapide-global)
- [Pour aller plus loin](#pour-aller-plus-loin)
- [Mise en place de la CI/CD Docker avec GitHub Actions](#mise-en-place-de-la-cicd-docker-avec-github-actions)
   - [Versionning automatique](#versionning-automatique)
   - [Scripts et rapports](#scripts-et-rapports)
- [Validation des images Docker dans la CI/CD](#validation-des-images-docker-dans-la-ci-cd)
- [FAQ – Problèmes courants](#faq--probl%C3%A8mes-courants)


## Structure du dépôt

- `Frontend/` : Application Angular (frontend)
- `Backend/` : Application Java Spring Boot (backend)

Chaque dossier contient :
- Son propre `README.md` détaillant l’installation, le build, les tests et l’utilisation spécifique à l’application.
- Un `Dockerfile` pour la conteneurisation.
- Un `docker-compose.yml` pour le lancement indépendant.

## Lancement rapide (global)

Pour lancer chaque application séparément :

```sh
# Backend
cd Backend
# Build et lancement
./gradlew bootJar
docker compose up -d

# Frontend
cd ../Frontend
# Build et lancement
npm install
npm run build --prod
docker compose up -d
```

## Pour aller plus loin

  - [README Angular](Frontend/README.md)
  - [README Java](Backend/README.md)

## Mise en place de la CI/CD Docker avec GitHub Actions

Ce dépot utilise un pipeline GitHub Actions réutilisable (`.github/workflows/ci.yml`) pour :
- lancer tous les tests via `run-tests.sh` (Angular + Spring Boot),
- construire et pousser les images Docker vers GitHub Container Registry (back et front),
- valider les images via `docker compose up` + vérification d’un endpoint,
- fusionner tous les rapports JUnit (`test-results/*.xml`) dans `Report-summary.xml` puis afficher un résumé directement dans la page GitHub Actions à l’aide du job `merge-report`.

### Versionning automatique

- Nous utilisons `semantic-release` avec les conventions Conventional Commits pour déterminer `major`, `minor`, `patch` sans intervention manuelle.
- Les commits `fix:` déclenchent un patch (`vX.Y.Z`), `feat:` un minor, et `BREAKING CHANGE` une release majeure.
- Les branches `main` et `dev` sont déclarées dans `.github/release.config.js` ; `main` publie des releases stables (tags `vX.Y.Z`), `dev` génère des prereleases (`vX.Y.Z-dev.N`).
- Exemple de commande pour créer un commit visible dans le changelog : `git commit -am "feat: align release docs"`.

L’étape `merge-report` souhaite expliciter le résultat des tests : elle télécharge l’artéfact `test-results-all`, liste son contenu et extrait la partie texte de `Report-summary.xml` pour l’insérer dans `GITHUB_STEP_SUMMARY`.

### Scripts et rapports

`run-tests.sh` (à la racine) détecte dynamiquement les projets Angular ou Spring Boot, exécute leurs suites de tests, exporte les rapports JUnit dans `test-results/` et produit un résumé `Report-summary.xml`. Ce fichier est réinitialisé avant chaque lancement et les artefacts sont téléchargés par `merge-report` lors de la phase finale.

## Validation des images Docker dans la CI/CD

Après le push d'une image Docker sur GitHub Container Registry, il est recommandé d'ajouter un job de validation dans le workflow CI/CD.

Ce job doit :
- Récupérer l'image (pull)
- Démarrer un conteneur (run)
- Vérifier que l'application fonctionne (ex : test d'un endpoint, vérification d'un log)
- Arrêter et supprimer le conteneur

Exemple de job GitHub Actions pour une application exposant un endpoint /health sur le port 8080 :

```yaml
# Job de validation après le push Docker
- name: Pull and test Docker image
   run: |
      docker pull ghcr.io/${{ github.repository }}:${{ github.sha }}
      docker run -d --name test-app -p 8080:8080 ghcr.io/${{ github.repository }}:${{ github.sha }}
      # Attendre que l'application démarre
      sleep 10
      # Vérifier le endpoint /health (adapter selon le projet)
      curl -f http://localhost:8080/health || exit 1
      # Nettoyer le conteneur
      docker rm -f test-app
```

> Adaptez le port, le nom du conteneur et le endpoint selon votre application (Angular ou Java).

Pour permettre à GitHub Actions de builder et pousser des images Docker vers GitHub Container Registry (ghcr.io), il faut :

1. **Créer un Personal Access Token (PAT) classic sur GitHub**
   - Les tokens fine-grained ne fonctionnent pas toujours pour le push Docker.
   - Le PAT doit avoir les droits :
     - `write:packages` (obligatoire pour le push)
     - `repo` (pour les actions sur le code)
     - `workflow` (pour exécuter les workflows)
2. **Ajouter ce PAT comme secret dans le dépôt GitHub**
   - Menu : Settings > Secrets and variables > Actions
   - Le nom du secret doit correspondre à celui utilisé dans le workflow (ex : `CI-ACTION-TOKEN` ou `ACTIONS_TOKEN`).
3. **Configurer le workflow pour utiliser ce secret**
   - Exemple pour le login Docker :
     ```yaml
     - name: Log in to GitHub Container Registry
       uses: docker/login-action@v3
       with:
         registry: ghcr.io
         username: ${{ github.actor }}
         password: ${{ secrets.CI-ACTION-TOKEN }}
     ```

Si le PAT n’a pas les bons droits, ou si le secret est absent/mal orthographié, le push Docker échouera.

**Résumé :**
- Utiliser un PAT classic avec les droits `write:packages`, `repo`, `workflow`.
- Ajouter ce PAT comme secret dans le repo.
- Vérifier la déclaration correcte dans le workflow.
---


Pour toute question ou détail technique, référez-vous aux documentations internes de chaque projet.

# FAQ – Problèmes courants
# Erreurs Docker CI/CD avec GitHub Actions

## Erreurs fréquentes lors du push Docker

- **Error: Password required**
   - Le secret PAT n'est pas transmis ou mal orthographié dans le workflow.
- **Token absent**
   - Le secret PAT n'existe pas ou n'est pas accessible dans le repo.
- **permission_denied: The token provided does not match expected scopes**
   - Le PAT n'a pas les droits `write:packages` ou n'est pas un PAT classic.

Vérifiez la section explicative ci-dessus pour la solution détaillée.

## Erreur Gradle : Could not find or load main class worker.org.gradle.process.internal.worker.GradleWorkerMain

Si vous rencontrez cette erreur lors de l'exécution des tests ou du build Java, il est probable qu'elle soit liée à l'emplacement du cache Gradle, en particulier si votre dossier utilisateur Windows contient des accents ou des caractères spéciaux. Cela peut provoquer des dysfonctionnements avec Gradle.

**Correctif recommandé :**

Définissez explicitement la variable d'environnement `GRADLE_USER_HOME` vers un dossier sans accents ni caractères spéciaux (par exemple `C:\gradle-cache`).

Exemple sous Windows :

```powershell
$env:GRADLE_USER_HOME="C:\\gradle-cache"
```
Ou dans un fichier `.env` ou dans la configuration de votre terminal/shell.

Ensuite, supprimez les anciens dossiers `.gradle` :
1. Supprimez le dossier `.gradle` à la racine du projet.
2. Supprimez le dossier `.gradle` dans `C:\Users\VOTRE_UTILISATEUR\.gradle` (remplacez VOTRE_UTILISATEUR par votre nom d'utilisateur Windows).
3. **Ne supprimez pas** le fichier `gradle/wrapper/gradle-wrapper.jar` ! Si ce fichier est absent ou corrompu :
   - Restaurez-le à partir d'un autre projet fonctionnel (même version Gradle),
   - ou téléchargez-le depuis le dépôt officiel Gradle ([voir documentation officielle](https://docs.gradle.org/current/userguide/gradle_wrapper.html)).
4. Une fois le jar présent, regénérez le wrapper avec :
   ```bash
   ./gradlew wrapper --gradle-version 8.7
   ```
5. Relancez la commande :
   ```bash
   ./gradlew clean build --refresh-dependencies
   ```

Cela va forcer Gradle à retélécharger toutes les dépendances et corriger la plupart des problèmes de cache ou de wrapper corrompu. Si le problème persiste, vérifiez que la variable d'environnement est bien prise en compte.

## Node.js 24 et dépréciation des actions

Depuis avril 2024, GitHub Actions déprécie les versions Node.js 20 pour les actions JavaScript. Le projet utilise Node.js 24 pour garantir la compatibilité future :
- Le Dockerfile frontend utilise `FROM node:24`.
- La variable d'environnement `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` est définie dans le workflow CI.
- Les actions GitHub sont mises à jour pour supporter Node.js 24.

## Versioning automatique avec semantic-release

Le projet utilise [semantic-release](https://github.com/semantic-release/semantic-release) pour publier automatiquement les versions et alimenter `CHANGELOG.md`. Le workflow `.github/workflows/release.yml` s’exécute sur les branches `dev` et `main`, installe les plugins (`changelog`, `git`, `github`) avec Node 24, puis exécute `npx semantic-release` avec `GITHUB_TOKEN` pointant vers le secret `ACTIONS_TOKEN` (PAT classic avec scopes `repo`, `packages:write`, `workflow`).

Pour que semantic-release puisse push/tagger les commits, assure-toi que la protection des branches `dev`/`main` permet au bot (`github-actions[bot]`) ou au compte associé au PAT de contourner les restrictions `Restrict updates/creations/deletions`. Le workflow écrit également des commentaires/labels (`released on @dev`) sur les PRs concernées.

### Convention et propagation

- Utilise [Conventional Commits](https://www.conventionalcommits.org) pour déclencher un `patch`/`minor`/`major`.
- `SEMANTIC_RELEASE` met à jour `CHANGELOG.md`, crée un tag `vX.Y.Z` et publie une release GitHub (visible sur la page Releases et via `git tag`).
- La release sur `dev` peut ensuite être mergée sur `main` (sans changer la version si aucun commit nouveau), ce qui maintient le changelog/tag en cohérence.
- Quand une release est publiée, le workflow pousse aussi le package frontend vers GitHub Packages (registre npm `npm.pkg.github.com`) et l'artefact backend vers GitHub Packages (registre Maven `maven.pkg.github.com`) avec le même `ACTIONS_TOKEN`.
- Le job `release` reconstruit puis retague les images Docker (`backend-vX.Y.Z` et `frontend-vX.Y.Z`) avec la version sémantique avant de les pousser vers GitHub Container Registry, garantissant que chaque release trouve ses artefacts versionnés.
- Avant chaque commit de release, le script `scripts/sync-version.js` met à jour `package.json` et `Backend/build.gradle` pour synchroniser la version calculée par semantic-release, puis `@semantic-release/git` ajoute ces fichiers à la release. Ce script est écrit en JavaScript pour pouvoir être exécuté directement par `node` sans compilation TypeScript supplémentaire dans le pipeline.

## Rapport JUnit XML et affichage dans le CI/CD

Les tests frontend et backend génèrent des rapports au format JUnit XML :
- Les rapports sont placés dans le dossier `test-results/` à la racine du projet.
- Une étape `merge-report` dans le workflow CI lit tous les fichiers XML et affiche un résumé dans le job summary GitHub Actions.
- Cela permet de visualiser rapidement le résultat des tests directement dans l'interface CI/CD.

Exemple :
```
test-results/
   TEST-fr.oc.devops.backend.services.NotionServiceTest.xml
   TEST-fr.oc.devops.backend.services.WorkshopServiceTest.xml
   TESTS-Chrome_Headless_145.0.0.0_(Windows_10).xml
```

Pour plus d'informations sur le format JUnit XML : https://github.com/test-results/junitxml

## Commit message and changelog semantics

- Only commits starting with `feat:`, `fix:`, or containing `BREAKING CHANGE:` are included in the changelog by default.
- Commits like `refactor:`, `chore:`, `test:`, `docs:`, `style:` are usually excluded unless configured otherwise.
- Branch names do not affect the changelog, only commit types matter.
