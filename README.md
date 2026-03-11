# Projet 6 – Déploiement Frontend & Backend avec Docker

Ce dépôt contient l’ensemble des livrables pour le projet 6 : l’application Angular (frontend) et l’application Java Spring Boot (backend), toutes deux prêtes à être conteneurisées et orchestrées avec Docker.

## Structure du dépôt

- `G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/` : Application Angular (frontend)
- `G-rez-l-int-gration-et-la-livraison-continue-Application-Java/` : Application Java Spring Boot (backend)

Chaque dossier contient :
- Son propre `README.md` détaillant l’installation, le build, les tests et l’utilisation spécifique à l’application.
- Un `Dockerfile` pour la conteneurisation.
- Un `docker-compose.yml` pour le lancement indépendant.

## Lancement rapide (global)

Pour lancer chaque application séparément :

```sh
# Backend
cd G-rez-l-int-gration-et-la-livraison-continue-Application-Java
# Build et lancement
./gradlew bootJar
docker compose up -d

# Frontend
cd ../G-rez-l-int-gration-et-la-livraison-continue-Application-Angular
# Build et lancement
npm install
npm run build --prod
docker compose up -d
```

## Pour aller plus loin

- Pour la configuration, les tests, la CI/CD, consultez les README spécifiques dans chaque dossier :
  - [README Angular](G-rez-l-int-gration-et-la-livraison-continue-Application-Angular/README.md)
  - [README Java](G-rez-l-int-gration-et-la-livraison-continue-Application-Java/README.md)

---

Pour toute question ou détail technique, référez-vous aux documentations internes de chaque projet.
