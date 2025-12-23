/*
	DistroMap - Metrics Handler
	===========================
	Handles Prometheus-compatible metrics endpoint.
*/

/**
 * Metrics endpoint (Prometheus-compatible)
 */
func handleMetricsRequest() {
	incrementMetric(:requestsTotal)
	incrementEndpointMetric(:metrics)
	incrementMetric(:requestsSuccessful)
	
	logRequest("/metrics", "")
	
	if (!METRICS_ENABLED) {
		aError = [:error = "Metrics endpoint is disabled"]
		sendJsonResponse(aError, 404, 0)
		return
	}
	
	// Get copy of metrics
	aMetrics = getMetrics()
	
	// Calculate uptime
	nUptimeSeconds = getUptimeSeconds()
	
	// Build Prometheus-compatible metrics
	cMetrics = "# HELP distromap_requests_total Total number of HTTP requests" + nl
	cMetrics = cMetrics + "# TYPE distromap_requests_total counter" + nl
	cMetrics = cMetrics + "distromap_requests_total " + aMetrics[:requestsTotal] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_requests_successful Total successful requests" + nl
	cMetrics = cMetrics + "# TYPE distromap_requests_successful counter" + nl
	cMetrics = cMetrics + "distromap_requests_successful " + aMetrics[:requestsSuccessful] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_requests_failed Total failed requests" + nl
	cMetrics = cMetrics + "# TYPE distromap_requests_failed counter" + nl
	cMetrics = cMetrics + "distromap_requests_failed " + aMetrics[:requestsFailed] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_not_found_total Total 404 responses" + nl
	cMetrics = cMetrics + "# TYPE distromap_not_found_total counter" + nl
	cMetrics = cMetrics + "distromap_not_found_total " + aMetrics[:notFoundCount] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_fuzzy_matches_total Total fuzzy match hits" + nl
	cMetrics = cMetrics + "# TYPE distromap_fuzzy_matches_total counter" + nl
	cMetrics = cMetrics + "distromap_fuzzy_matches_total " + aMetrics[:fuzzyMatchCount] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_requests_by_endpoint Requests per endpoint" + nl
	cMetrics = cMetrics + "# TYPE distromap_requests_by_endpoint counter" + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="distro"} ' + aMetrics[:requestsByEndpoint][:distro] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="products"} ' + aMetrics[:requestsByEndpoint][:products] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="compare"} ' + aMetrics[:requestsByEndpoint][:compare] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="health"} ' + aMetrics[:requestsByEndpoint][:health] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="metrics"} ' + aMetrics[:requestsByEndpoint][:metrics] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="root"} ' + aMetrics[:requestsByEndpoint][:root] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_uptime_seconds Server uptime in seconds" + nl
	cMetrics = cMetrics + "# TYPE distromap_uptime_seconds gauge" + nl
	cMetrics = cMetrics + "distromap_uptime_seconds " + floor(nUptimeSeconds) + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_database_products Number of products in database" + nl
	cMetrics = cMetrics + "# TYPE distromap_database_products gauge" + nl
	cMetrics = cMetrics + "distromap_database_products " + getProductCount() + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_database_updates Total database updates" + nl
	cMetrics = cMetrics + "# TYPE distromap_database_updates counter" + nl
	cMetrics = cMetrics + "distromap_database_updates " + appState[:updateCount] + nl
	
	setCorsHeaders()
	oServer.setStatus(200)
	oServer.setContent(cMetrics, "text/plain; version=0.0.4")
}
