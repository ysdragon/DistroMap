/*
	DistroMap - Health Handler
	==========================
	Handles health check endpoint.
*/

/**
 * Health check endpoint
 */
func handleHealthCheck() {
	incrementMetric(:requestsTotal)
	incrementEndpointMetric(:health)
	incrementMetric(:requestsSuccessful)
	
	logRequest("/health", "")
	
	// Calculate uptime using timelist()
	nUptimeSeconds = getUptimeSeconds()
	nUptimeMinutes = floor(nUptimeSeconds / 60)
	nUptimeHours = floor(nUptimeMinutes / 60)
	nUptimeDays = floor(nUptimeHours / 24)
	
	cUptime = string(nUptimeDays) + "d " + (nUptimeHours % 24) + "h " + (nUptimeMinutes % 60) + "m " + floor(nUptimeSeconds % 60) + "s"
	
	// Check upstream status
	checkUpstreamStatus()
	
	aHealth = [
		:status = "healthy",
		:version = API_VERSION,
		:timestamp = getFormattedTimestamp(),
		:uptime = cUptime,
		:database = [
			:loaded = isDatabaseLoaded(),
			:product_count = getProductCount(),
			:last_update = appState[:lastUpdateTime],
			:update_count = appState[:updateCount]
		],
		:upstream = [
			:endoflife_date = appState[:upstreamStatus],
			:last_check = appState[:upstreamLastCheck],
			:api_url = API_BASE_URL
		]
	]

	sendJsonResponse(aHealth, 200, 0)
}

/**
 * Check if upstream API (endoflife.date) is reachable
 */
func checkUpstreamStatus() {
	try {
		curl = curl_easy_init()
		if (!isNull(curl)) {
			// Just do a HEAD request to check connectivity
			curl_easy_setopt(curl, CURLOPT_URL, "https://endoflife.date/api/v1/products")
			curl_easy_setopt(curl, CURLOPT_NOBODY, 1)
			curl_easy_setopt(curl, CURLOPT_TIMEOUT, UPSTREAM_CHECK_TIMEOUT)
			curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, SSL_VERIFY_PEER)
			curl_easy_setopt(curl, CURLOPT_USERAGENT, USER_AGENT)
			
			curl_easy_perform_silent(curl)
			nStatus = curl_getResponseCode(curl)
			curl_easy_cleanup(curl)
			
			if (nStatus >= 200 && nStatus < 400) {
				appState[:upstreamStatus] = "reachable"
			else
				appState[:upstreamStatus] = "error (HTTP " + nStatus + ")"
			}
		else
			appState[:upstreamStatus] = "unknown (curl init failed)"
		}
	catch
		appState[:upstreamStatus] = "unreachable"
	}
	appState[:upstreamLastCheck] = getFormattedTimestamp()
}
