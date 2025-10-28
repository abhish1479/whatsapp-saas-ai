# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Accept build-time args from Compose or Azure
COPY . .
ARG API_HOST=localhost
ARG API_PORT=8000
ARG API_BASE=http://localhost:8000

# Enable web and build with injected envs
RUN flutter config --enable-web
RUN flutter build web --release \
  --dart-define=API_HOST=$API_HOST \
  --dart-define=API_PORT=$API_PORT \
  --dart-define=API_BASE=$API_BASE

# Stage 2: Serve via Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]