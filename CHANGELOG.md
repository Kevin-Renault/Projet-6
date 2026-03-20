# 1.0.0 (2026-03-20)


### Bug Fixes

* ensure frontend job waits for container completion before workflow continues ([5e52172](https://github.com/Kevin-Renault/Projet-6/commit/5e52172ac5b6bed0bc3a12d1a10f4b6171cb89cd))
* remove empty with: ([7ceb5f1](https://github.com/Kevin-Renault/Projet-6/commit/7ceb5f19066a27e2c7381a296cb81f1d5ef87686))
* remove infinite wait for frontend container, workflow now waits for tests container completion ([2a49afa](https://github.com/Kevin-Renault/Projet-6/commit/2a49afa55da0451f5cdec55e6f8162cb95de847b))
* update nginx config to serve Angular build from /usr/share/nginx/html ([287a363](https://github.com/Kevin-Renault/Projet-6/commit/287a3634f7d6de7622575d5ea4265bebae4c131d))


### Features

* add Dockerfile and docker-compose for front ([30b5ebd](https://github.com/Kevin-Renault/Projet-6/commit/30b5ebd8050cccaa6f199a896c73b6246a93e4f7))
* inject coverage summary with percentages into Angular test XML ([2bcbf17](https://github.com/Kevin-Renault/Projet-6/commit/2bcbf1754ed05c94fcfd967f989c984e3c765fad))
* run Angular tests in dedicated Docker service and update workflow accordingly ([50b941a](https://github.com/Kevin-Renault/Projet-6/commit/50b941a66b4820c29d1aef2a36a0b2f15b3ac1fe))

# Changelog

Ce fichier est généré automatiquement par semantic-release.

Toutes les versions et changements seront listés ici après le premier release automatique.
