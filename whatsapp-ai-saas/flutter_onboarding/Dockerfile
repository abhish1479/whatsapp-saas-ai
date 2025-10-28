# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable as build

WORKDIR /app
COPY . .

# Define build args
ARG API_HOST
ARG API_PORT
ARG API_BASE

# Print them to confirm at build time
RUN echo "Building with API_HOST=$API_HOST, API_PORT=$API_PORT, API_BASE=$API_BASE"

RUN flutter config --enable-web
RUN flutter pub get

# 👇 Here we expand ARGs into actual Flutter --dart-define flags
RUN flutter build web --release \
    --dart-define=API_HOST=${API_HOST:-localhost} \
    --dart-define=API_PORT=${API_PORT:-8000} \
    --dart-define=API_BASE=${API_BASE:-http://localhost:8000}

# Stage 2: Serve via Nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
