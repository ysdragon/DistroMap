/*
	DistroMap - Metrics Handler
	===========================
	Handles Prometheus-compatible metrics endpoint.
*/

/**
 * Metrics endpoint (Prometheus-compatible)
 */
func handleMetricsRequest() {
	metrics[:requestsTotal] = metrics[:requestsTotal] + 1
	metrics[:requestsByEndpoint][:metrics] = metrics[:requestsByEndpoint][:metrics] + 1
	metrics[:requestsSuccessful] = metrics[:requestsSuccessful] + 1
	
	logRequest("/metrics", "")
	
	if (!METRICS_ENABLED) {
		aError = [:error = "Metrics endpoint is disabled"]
		sendJsonResponse(aError, 404, 0)
		return
	}
	
	// Calculate uptime
	nUptimeSeconds = getUptimeSeconds()
	
	// Build Prometheus-compatible metrics
	cMetrics = "# HELP distromap_requests_total Total number of HTTP requests" + nl
	cMetrics = cMetrics + "# TYPE distromap_requests_total counter" + nl
	cMetrics = cMetrics + "distromap_requests_total " + metrics[:requestsTotal] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_requests_successful Total successful requests" + nl
	cMetrics = cMetrics + "# TYPE distromap_requests_successful counter" + nl
	cMetrics = cMetrics + "distromap_requests_successful " + metrics[:requestsSuccessful] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_requests_failed Total failed requests" + nl
	cMetrics = cMetrics + "# TYPE distromap_requests_failed counter" + nl
	cMetrics = cMetrics + "distromap_requests_failed " + metrics[:requestsFailed] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_not_found_total Total 404 responses" + nl
	cMetrics = cMetrics + "# TYPE distromap_not_found_total counter" + nl
	cMetrics = cMetrics + "distromap_not_found_total " + metrics[:notFoundCount] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_fuzzy_matches_total Total fuzzy match hits" + nl
	cMetrics = cMetrics + "# TYPE distromap_fuzzy_matches_total counter" + nl
	cMetrics = cMetrics + "distromap_fuzzy_matches_total " + metrics[:fuzzyMatchCount] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_requests_by_endpoint Requests per endpoint" + nl
	cMetrics = cMetrics + "# TYPE distromap_requests_by_endpoint counter" + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="distro"} ' + metrics[:requestsByEndpoint][:distro] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="products"} ' + metrics[:requestsByEndpoint][:products] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="compare"} ' + metrics[:requestsByEndpoint][:compare] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="health"} ' + metrics[:requestsByEndpoint][:health] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="metrics"} ' + metrics[:requestsByEndpoint][:metrics] + nl
	cMetrics = cMetrics + 'distromap_requests_by_endpoint{endpoint="root"} ' + metrics[:requestsByEndpoint][:root] + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_uptime_seconds Server uptime in seconds" + nl
	cMetrics = cMetrics + "# TYPE distromap_uptime_seconds gauge" + nl
	cMetrics = cMetrics + "distromap_uptime_seconds " + floor(nUptimeSeconds) + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_database_products Number of products in database" + nl
	cMetrics = cMetrics + "# TYPE distromap_database_products gauge" + nl
	cMetrics = cMetrics + "distromap_database_products " + len(aProductsData[:result]) + nl + nl
	
	cMetrics = cMetrics + "# HELP distromap_database_updates Total database updates" + nl
	cMetrics = cMetrics + "# TYPE distromap_database_updates counter" + nl
	cMetrics = cMetrics + "distromap_database_updates " + appState[:updateCount] + nl
	
	setCorsHeaders()
	oServer.setStatus(200)
	oServer.setContent(cMetrics, "text/plain; version=0.0.4")
}
