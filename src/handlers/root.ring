/*
	DistroMap - Root Handler
	========================
	Handles root endpoint and CORS preflight requests.
*/

/**
 * Root endpoint - serves HTML page
 */
func handleRootRequest() {
	metrics[:requestsTotal] = metrics[:requestsTotal] + 1
	metrics[:requestsByEndpoint][:root] = metrics[:requestsByEndpoint][:root] + 1
	metrics[:requestsSuccessful] = metrics[:requestsSuccessful] + 1
	
	logRequest("/", "HTML page")
	
	setCorsHeaders()
	cHtmlContent = read("src/public/index.html")
	
	// Replace placeholders
	cHtmlContent = substr(cHtmlContent, "{{API_VERSION}}", API_VERSION)
	cHtmlContent = substr(cHtmlContent, "{{RING_VERSION}}", version(true))
	cHtmlContent = substr(cHtmlContent, "{{BASE_URL}}", BASE_URL)
	
	// Conditionally show metrics endpoint and badge
	if (METRICS_ENABLED) {
		cMetricsHtml = "      <div class='endpoint'>
        <div class='endpoint-header'>
          <strong>Prometheus metrics:</strong>
          <button class='copy-btn' data-copy='curl " + BASE_URL + "/metrics'>📋 Copy curl</button>
        </div>
        <code>GET /metrics</code><br>
        <span class='endpoint-desc'>Returns Prometheus-compatible metrics for monitoring</span>
        <details class='response-preview'>
          <summary>View sample response</summary>
          <pre># HELP distromap_requests_total Total requests
# TYPE distromap_requests_total counter
distromap_requests_total 1234

# HELP distromap_uptime_seconds Server uptime
# TYPE distromap_uptime_seconds gauge
distromap_uptime_seconds 86400</pre>
        </details>
      </div>"
		cHtmlContent = substr(cHtmlContent, "{{METRICS_ENDPOINT}}", cMetricsHtml)
		cHtmlContent = substr(cHtmlContent, "{{METRICS_BADGE}}", "<span class='badge'>📊 Prometheus Metrics</span>")
	else
		cHtmlContent = substr(cHtmlContent, "{{METRICS_ENDPOINT}}", "")
		cHtmlContent = substr(cHtmlContent, "{{METRICS_BADGE}}", "")
	}
	
	oServer.setStatus(200)
	oServer.setContent(cHtmlContent, "text/html")
}

/**
 * Handle OPTIONS preflight requests for CORS
 */
func handleOptionsRequest() {
	metrics[:requestsTotal] = metrics[:requestsTotal] + 1
	setCorsHeaders()
	oServer.setStatus(204)
	oServer.setContent("", "text/plain")
}
