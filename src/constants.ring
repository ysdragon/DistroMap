// Server Configuration
API_VERSION = "1.2.0"
SERVER_HOST = getEnvVar("SERVER_HOST", "0.0.0.0")
SERVER_PORT = number(getEnvVar("SERVER_PORT", "8080"))
BASE_URL = getEnvVar("BASE_URL", "http://localhost:" + SERVER_PORT)
USER_AGENT =  "DistroMap-API/" + API_VERSION

// API Configuration
API_BASE_URL = "https://endoflife.date/api/v1/products/full"
UPDATE_INTERVAL = number(getEnvVar("UPDATE_INTERVAL", "6"))
UPDATE_INTERVAL_MS = UPDATE_INTERVAL * 60 * 60 * 1000

// Logging Configuration
DEBUG = getEnvVar("DEBUG", "false") = "true"

// Security Configuration
SSL_VERIFY_PEER = getEnvVar("SSL_VERIFY_PEER", "true") = "true"

// CORS Configuration
CORS_ENABLED = getEnvVar("CORS_ENABLED", "true") = "true"
CORS_ORIGIN = getEnvVar("CORS_ORIGIN", "*")
CORS_METHODS = getEnvVar("CORS_METHODS", "GET, OPTIONS")
CORS_HEADERS = getEnvVar("CORS_HEADERS", "Content-Type, Accept")

// Caching Configuration
CACHE_MAX_AGE = number(getEnvVar("CACHE_MAX_AGE", "300"))  // 5 minutes default

// Request Logging Configuration
REQUEST_LOGGING = getEnvVar("REQUEST_LOGGING", "true") = "true"

// Metrics Configuration
METRICS_ENABLED = getEnvVar("METRICS_ENABLED", "false") = "true"

// Helper function to get environment variable with default
func getEnvVar(envName, defaultValue) {
    envValue = sysGet(envName)
    if (isNull(envValue)) {
        return defaultValue
    else
        return envValue
    }
}