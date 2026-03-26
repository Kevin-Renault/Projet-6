# Présentation des critères d'autoévaluation


## Exercice 1 – Conteneurisation des applications

- **Les deux applications s'exécutent localement sans erreur**
  > Les applications Angular et Java Spring Boot ont été testées localement, assurant une base saine avant la conteneurisation.
  >
  > **Commande démo :**
  > ```sh
  > # Lancer le backend
  > cd Backend
  > ./gradlew bootRun
  > # Lancer le frontend
  > cd /Frontend
  > npm install
  > npm start
  > ```
- **Les deux applications s'exécutent localement sans erreur**
  > Les applications Angular et Java Spring Boot ont été testées localement, assurant une base saine avant la conteneurisation.
- **Les commandes de build et d'exécution des README fonctionnent**
  > Toutes les commandes documentées dans les README ont été validées, garantissant la reproductibilité de l'installation.
  >
  > **Commande démo :**
  > ```sh
  > # Backend
  > cd Backend
  > ./gradlew bootJar
  > docker compose up -d
  > # Frontend
  > cd ../Frontend
  > npm install
  > npm run build --prod
  > docker compose up -d
  > ```
- **Les ports nécessaires sont identifiés et disponibles**
  > Les ports requis (80 pour le front, 8080 pour le back) ont été vérifiés et réservés pour éviter tout conflit.
  >
  > **Commande démo :**
  > ```sh
  > netstat -ano | findstr :80
  > netstat -ano | findstr :8080
  > ```
- **Les versions des outils correspondent aux prérequis**
  > Node, Java et Docker sont installés dans les versions recommandées, assurant la compatibilité des builds.
  >
  > **Commande démo :**
  > ```sh
  > node -v
  > java -version
  > docker --version
  > ```

### Étape 2 – Dockerisation du front-end Angular
- **Dockerfile multi-stage**
  > Un Dockerfile multi-stage optimise la taille de l'image finale, ne conservant que les fichiers nécessaires à la production.
  >
  > **Commande démo :**
  > ```sh
  > cat Frontend/Dockerfile
  > ```
- **Image finale avec uniquement les fichiers nécessaires**
  > Seul le dossier `dist/` est copié dans l'image Nginx, garantissant sécurité et légèreté.
  >
  > **Commande démo :**
  > ```sh
  > docker run --rm -it workshop-front ls /usr/share/nginx/html
  > ```
- **Présence d'un .dockerignore**
  > Un fichier `.dockerignore` exclut les fichiers inutiles du contexte de build.
  >
  > **Commande démo :**
  > ```sh
  > cat Frontend/.dockerignore
  > ```
- **docker-compose.yml fonctionnel**
  > Le fichier `docker-compose.yml` permet de lancer le front facilement, avec healthcheck intégré.
  >
  > **Commande démo :**
  > ```sh
  > docker compose -f Frontend/docker-compose.yml up -d
  > docker ps
  > ```
- **Application accessible via http://localhost**
  > Après `docker compose up -d`, l'application est accessible sur le port 80, preuve de la réussite de la conteneurisation.
  >
  > **Commande démo :**
  > ```sh
  > curl http://localhost
  > ```

### Étape 3 – Dockerisation du back-end Spring Boot
- **Dockerfile avec compilation Gradle**
  > Le Dockerfile compile l'application avec Gradle dans une image builder, puis ne conserve que le JAR pour l'exécution.
  >
  > **Commande démo :**
  > ```sh
  > cat Backend/Dockerfile
  > ```
- **Image finale avec JRE uniquement**
  > L'image d'exécution utilise une JRE légère, réduisant la surface d'attaque et la taille.
  >
  > **Commande démo :**
  > ```sh
  > docker run --rm -it workshop-organizer java -version
  > ```
- **docker-compose.yml avec deux services**
  > Le docker-compose orchestre l'application et la base PostgreSQL, facilitant le développement et les tests.
  >
  > **Commande démo :**
  > ```sh
  > cat Backend/docker-compose.yml
  > ```
- **Variables d'environnement pour la base**
  > Les credentials de la base sont injectés via des variables d'environnement, centralisant la configuration.
  >
  > **Commande démo :**
  > ```sh
  > docker compose -f Backend/docker-compose.yml config | grep SPRING_DATASOURCE
  > ```
- **Volume pour la persistance PostgreSQL**
  > Un volume Docker assure la persistance des données de la base, même après redémarrage des conteneurs.
  >
  > **Commande démo :**
  > ```sh
  > docker volume ls
  > ```
- **Health check pour l'orchestration**
  > Un healthcheck garantit que le back-end démarre seulement quand la base est prête.
  >
  > **Commande démo :**
  > ```sh
  > cat Backend/docker-compose.yml | grep healthcheck -A 5
  > ```
- **API accessible sur http://localhost:8080**
  > L'API répond sur le port 8080, validant la chaîne de conteneurisation.
  >
  > **Commande démo :**
  > ```sh
  > curl http://localhost:8080/actuator/health
  > ```

## Exercice 2 – Tests et CI/CD

### Étape 1 – Script d'exécution des tests
- **Détection automatique du type de projet**
  > Le script `run-tests.sh` identifie le type de projet et lance les tests adaptés.
  >
  > **Commande démo :**
  > ```sh
  > ./run-tests.sh
  > ```
- **Exécution correcte des tests**
  > Les tests unitaires du front et du back s'exécutent sans erreur, assurant la qualité du code.
  >
  > **Commande démo :**
  > ```sh
  > ./run-tests.sh
  > cat test-results/Report-summary.xml
  > ```
- **Rapport JUnit XML généré**
  > Les résultats sont exportés au format JUnit XML, facilitant l'intégration CI/CD.
  >
  > **Commande démo :**
  > ```sh
  > ls test-results/*.xml
  > ```
- **Rapport placé dans `test-results/`**
  > Tous les rapports sont centralisés dans le dossier `test-results/` à la racine.
  >
  > **Commande démo :**
  > ```sh
  > ls test-results/
  > ```
- **Code de sortie approprié**
  > Le script retourne 0 en cas de succès, ou un code d'erreur sinon, pour une intégration CI fiable.
  >
  > **Commande démo :**
  > ```sh
  > echo $?
  > ```
- **Nettoyage des artefacts de tests précédents**
  > Avant chaque exécution, les anciens rapports sont supprimés pour éviter toute confusion.
  >
  > **Commande démo :**
  > ```sh
  > ./run-tests.sh
  > # puis ls test-results/ pour vérifier le nettoyage
  > ```

### Étape 2 – Pipeline CI réutilisable
- **Stage test dans le pipeline**
  > Le pipeline CI (GitHub Actions) inclut un stage de test pour chaque push ou PR.
  >
  > **Commande démo :**
  > ```yaml
  > # Voir .github/workflows/ci.yml
  > ```
- **Job de test adaptable aux deux projets**
  > Les jobs s'adaptent via variables d'environnement, permettant la mutualisation du pipeline.
  >
  > **Commande démo :**
  > ```yaml
  > # Voir .github/workflows/ci.yml
  > ```
- **Intégration du rapport de test**
  > Les rapports JUnit sont uploadés comme artefacts et résumés dans le job summary.
  >
  > **Commande démo :**
  > ```yaml
  > # Voir .github/workflows/ci.yml (étape Upload all JUnit test results)
  > ```
- **Mise en cache des dépendances**
  > Les dépendances sont mises en cache pour accélérer les builds (voir jobs d'installation dans le pipeline).
  >
  > **Commande démo :**
  > ```yaml
  > # Voir .github/workflows/ci.yml (jobs d'installation)
  > ```
- **Déclenchement sur push/MR**
  > Le pipeline s'exécute automatiquement à chaque push ou merge request.
  >
  > **Commande démo :**
  > ```yaml
  > # Voir on: push dans .github/workflows/ci.yml
  > ```

### Étape 3 – Stage de build dans le pipeline
- **Stage build ajouté au pipeline**
  > Un stage dédié construit les images Docker pour chaque application.
  >
  > **Commande démo :**
  > ```yaml
  > # Voir jobs build-and-push-backend et build-and-push-frontend dans .github/workflows/ci.yml
  > ```
- **Build et push des images Docker**
  > Les images sont construites puis poussées vers la registry GitHub/GitLab.
  >
  > **Commande démo :**
  > ```sh
  > docker images | grep workshop
  > # Voir aussi jobs de push dans .github/workflows/ci.yml
  > ```
- **Tag avec SHA du commit et nom de branche**
  > Chaque image est taguée de façon unique pour assurer la traçabilité.
  >
  > **Commande démo :**
  > ```sh
  > # Voir jobs build-and-push-* dans .github/workflows/ci.yml
  > ```
- **Pipeline fonctionnel pour les deux apps**
  > Le pipeline gère aussi bien le front que le back, garantissant une CI/CD homogène.
  >
  > **Commande démo :**
  > ```yaml
  > # Voir .github/workflows/ci.yml
  > ```

### Étape 4 – Intégration de semantic-release
- **Installation et configuration de semantic-release**
  > semantic-release automatise la gestion des versions et la génération du changelog.
  >
  > **Commande démo :**
  > ```sh
  > cat release.config.js
  > ```
- **Stage release dans le pipeline**
  > Un job dédié publie les releases et met à jour les artefacts.
  >
  > **Commande démo :**
  > ```yaml
  > # Voir .github/workflows/release.yml
  > ```
- **Adoption de Conventional Commits**
  > Les commits respectent la convention, déclenchant automatiquement les releases.
  >
  > **Commande démo :**
  > ```sh
  > git log --oneline --decorate
  > # Les messages doivent suivre la convention Conventional Commits
  > ```
- **Génération automatique du changelog**
  > Le changelog est mis à jour à chaque release, assurant la transparence.
  >
  > **Commande démo :**
  > ```sh
  > cat CHANGELOG.md
  > ```
  Seuls les commits commençant par `feat:`, `fix:` ou contenant `BREAKING CHANGE:` sont inclus par défaut dans le changelog généré automatiquement. Les autres types (`refactor:`, `chore:`, etc.) sont exclus sauf configuration spécifique.

- **Tag Docker avec version sémantique**
  > Les images Docker sont taguées avec la version, facilitant le déploiement.
  >
  > **Commande démo :**
  > ```sh
  > docker images | grep v[0-9]
  > ```
- **Déclenchement du job de release selon la stratégie**
  > Le job de release s'exécute selon la politique définie (branche main/dev).
  >
  > **Commande démo :**
  > ```yaml
  > # Voir on: dans .github/workflows/release.yml
  > ```
- **Synchronisation de la version dans les fichiers du projet**
  > Les fichiers `package.json` et `build.gradle` sont mis à jour automatiquement pour refléter la version courante.
  >
  > **Commande démo :**
  > ```sh
  > cat Frontend/package.json | grep version
  > cat Backend/build.gradle | grep version
  > ```
