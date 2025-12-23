/*
	DistroMap - Global State
	========================
	Central state management for the application.
*/

// Stores the entire product database from the API
aProductsData = NULL

// Stores the HTTPLib server object
oServer = NULL

// Application state
appState = [
	:lastUpdateTime = 0,
	:updateCount = 0,
	:startTime = [],
	:upstreamStatus = "unknown",
	:upstreamLastCheck = ""
]

// Metrics tracking
metrics = [
	:requestsTotal = 0,
	:requestsByEndpoint = [
		:distro = 0,
		:products = 0,
		:compare = 0,
		:health = 0,
		:metrics = 0,
		:root = 0
	],
	:requestsSuccessful = 0,
	:requestsFailed = 0,
	:notFoundCount = 0,
	:fuzzyMatchCount = 0
]

// Mutex for metrics access
metricsMutex = NULL

/**
 * Initialize the metrics mutex
 * Must be called before starting the HTTP server thread
 */
func initMetricsMutex() {
	metricsMutex = new_uv_mutex_t()
	uv_mutex_init(metricsMutex)
}

/**
 * Increment a specific metric
 * @param metricKey The key of the metric to increment (e.g., :requestsTotal)
 */
func incrementMetric(metricKey) {
	if (!isNull(metricsMutex)) {
		uv_mutex_lock(metricsMutex)
	}
	metrics[metricKey] = metrics[metricKey] + 1
	if (!isNull(metricsMutex)) {
		uv_mutex_unlock(metricsMutex)
	}
}

/**
 * Increment the request count for a specific endpoint
 * @param endpoint The endpoint key (e.g., :distro, :health)
 */
func incrementEndpointMetric(endpoint) {
	if (!isNull(metricsMutex)) {
		uv_mutex_lock(metricsMutex)
	}
	metrics[:requestsByEndpoint][endpoint] = metrics[:requestsByEndpoint][endpoint] + 1
	if (!isNull(metricsMutex)) {
		uv_mutex_unlock(metricsMutex)
	}
}

/**
 * Retrieve a copy of the metrics
 * @return Copy of metrics data
 */
func getMetrics() {
	if (!isNull(metricsMutex)) {
		uv_mutex_lock(metricsMutex)
	}
	aMetricsCopy = metrics
	if (!isNull(metricsMutex)) {
		uv_mutex_unlock(metricsMutex)
	}
	return aMetricsCopy
}
