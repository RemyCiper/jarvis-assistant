FROM ghcr.io/cirruslabs/flutter:3.47.7 AS flutter-build
WORKDIR /app
COPY . .
RUN flutter pub get && flutter build web

FROM node:22-bookworm-slim
WORKDIR /app
COPY backend/server.js ./backend/server.js
RUN npm install --omit=dev express cors dotenv
COPY --from=flutter-build /app/build/web ./build/web
ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "backend/server.js"]
