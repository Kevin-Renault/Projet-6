# Build de l'app Angular
FROM node:20 AS build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build --prod

# Serveur Nginx pour le front
FROM nginx:alpine
COPY --from=build /app/dist/olympic-games-starter/ /usr/share/nginx/html
COPY nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80