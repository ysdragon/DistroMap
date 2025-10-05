# Use the official Ring light image as base
FROM ysdragon/ring:light

# Set working directory
WORKDIR /app

# Copy all project files to the container
COPY . .

# Expose the default port
EXPOSE 8080

# Set environment variables with default values
ENV RING_FILE=main.ring
ENV RING_PACKAGES=simplejson
ENV SERVER_HOST=0.0.0.0
ENV SERVER_PORT=8080
ENV UPDATE_INTERVAL=6
ENV SSL_VERIFY_PEER=false
ENV DEBUG=false