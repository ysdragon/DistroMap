// Server Configuration
API_VERSION = "1.0.0"
SERVER_HOST = getEnvVar("SERVER_HOST", "0.0.0.0")
SERVER_PORT = number(getEnvVar("SERVER_PORT", "8080"))
USER_AGENT =  "DistroMap-API/" + API_VERSION

// API Configuration
API_BASE_URL = "https://endoflife.date/api/v1/products/full"
UPDATE_INTERVAL = number(getEnvVar("UPDATE_INTERVAL", "6"))
UPDATE_INTERVAL_MS = UPDATE_INTERVAL * 60 * 60 * 1000

// Logging Configuration
DEBUG = getEnvVar("DEBUG", "false") = "true"

// Security Configuration
SSL_VERIFY_PEER = getEnvVar("SSL_VERIFY_PEER", "false") = "true"

// Helper function to get environment variable with default
func getEnvVar(envName, defaultValue) {
    envValue = sysGet(envName)
    if (isNull(envValue)) {
        return defaultValue
    else
        return envValue
    }
}