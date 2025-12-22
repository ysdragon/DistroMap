/*
	DistroMap - HTTP Server
	=======================
	HTTP server setup and route definitions.
*/

/**
 * This function runs in a background thread and contains the blocking server.
 */
func startHttpServer() {
	logMessage([:message = "DistroMap API is now listening on " + SERVER_HOST + ":" + SERVER_PORT, :level = "SUCCESS", :color = :BRIGHT_GREEN])
	logMessage([:message = "Try: curl http://" + SERVER_HOST + ":" + SERVER_PORT + "/distro/ubuntu/noble", :level = "INFO", :color = :CYAN])
	logMessage([:message = "Health check: curl http://" + SERVER_HOST + ":" + SERVER_PORT + "/health", :level = "INFO", :color = :CYAN])
	logMessage([:message = "List products: curl http://" + SERVER_HOST + ":" + SERVER_PORT + "/products", :level = "INFO", :color = :CYAN])

	oServer = new Server {
		shareFolder("src/public/assets")
		
		// Root and static
		route(:Get, "/", :handleRootRequest)
		
		// Products endpoints
		route(:Get, "/products", :handleProductsRequest)
		route(:Get, "/products/([a-zA-Z0-9._-]+)", :handleProductReleasesRequest)
		
		// Distro endpoints
		route(:Get, "(/distro/([a-zA-Z0-9._-]+)/([a-zA-Z0-9._-]+))", :handleDistroRequest)
		route(:Get, "/distro/([a-zA-Z0-9._-]+)", :handleAllReleasesRequest)
		
		// Compare endpoint
		route(:Get, "/compare/([a-zA-Z0-9._-]+)/([a-zA-Z0-9._-]+)/([a-zA-Z0-9._-]+)/([a-zA-Z0-9._-]+)", :handleCompareRequest)
		
		// System endpoints
		route(:Get, "/health", :handleHealthCheck)
		route(:Get, "/metrics", :handleMetricsRequest)
		
		// CORS preflight
		route(:Options, ".*", :handleOptionsRequest)
		
		listen(SERVER_HOST, SERVER_PORT)
	}
}
