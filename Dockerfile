# Use the official Ring light image as base
FROM ysdragon/ring:nightly-light

# Build arguments
ARG VERSION=1.2.0
ARG BUILD_DATE
ARG VCS_REF

# Image labels
LABEL org.opencontainers.image.title="DistroMap API" \
      org.opencontainers.image.description="Linux distribution release information API" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/ysdragon/DistroMap" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.vendor="ysdragon"

# Set working directory
WORKDIR /app

# Copy all project files to the container
COPY . .

# Expose the default port
EXPOSE 8080

# Ring runtime settings
ENV RING_FILE=main.ring
ENV RING_PACKAGES=simplejson

# Server Settings
ENV SERVER_HOST=0.0.0.0
ENV SERVER_PORT=8080
ENV BASE_URL=http://localhost:8080
ENV UPDATE_INTERVAL=6
ENV SSL_VERIFY_PEER=true

# CORS Settings
ENV CORS_ENABLED=true
ENV CORS_ORIGIN=*
ENV CORS_METHODS="GET, OPTIONS"
ENV CORS_HEADERS="Content-Type, Accept"

# Caching & Logging
ENV CACHE_MAX_AGE=300
ENV REQUEST_LOGGING=true
ENV DEBUG=false

# Metrics (disabled by default for security)
ENV METRICS_ENABLED=false

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:${SERVER_PORT}/health || exit 1