# Build de l'app Angular
FROM node:24 AS build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build --prod

FROM nginx:alpine
# Supprimez l'index.html par défaut d'Nginx
RUN rm -f /usr/share/nginx/html/index.html
# Copiez votre app Angular
COPY --from=build /app/dist/olympic-games-starter/ /usr/share/nginx/html/
COPY nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 80