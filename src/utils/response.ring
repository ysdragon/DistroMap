/*
	DistroMap - Response Utilities
	==============================
	CORS, caching, and JSON response helper functions.
*/

/**
 * Sets CORS headers on the response
 */
func setCorsHeaders() {
	if (CORS_ENABLED) {
		oServer.response().set_header("Access-Control-Allow-Origin", CORS_ORIGIN)
		oServer.response().set_header("Access-Control-Allow-Methods", CORS_METHODS)
		oServer.response().set_header("Access-Control-Allow-Headers", CORS_HEADERS)
		oServer.response().set_header("Access-Control-Max-Age", CORS_MAX_AGE)
	}
}

/**
 * Sets caching headers on the response
 * @param nMaxAge Cache max age in seconds (0 to disable)
 */
func setCacheHeaders(nMaxAge) {
	if (nMaxAge > 0) {
		oServer.response().set_header("Cache-Control", "public, max-age=" + nMaxAge)
		// Use update count as ETag - changes whenever database updates
		if (!isNull(appState) && !isNull(appState[:updateCount])) {
			oServer.response().set_header("ETag", '"distromap-v' + appState[:updateCount] + '"')
		}
	else
		oServer.response().set_header("Cache-Control", "no-cache, no-store, must-revalidate")
	}
}

/**
 * Sends a JSON response with common headers
 * @param aData The data to encode as JSON
 * @param nStatus HTTP status code
 * @param nCacheAge Cache max age (0 to disable caching)
 */
func sendJsonResponse(aData, nStatus, nCacheAge) {
	setCorsHeaders()
	setCacheHeaders(nCacheAge)
	cJson = json_encode(aData)
	oServer.setStatus(nStatus)
	oServer.setContent(cJson, "application/json")
}

/**
 * Logs an incoming request
 * @param cEndpoint The endpoint being accessed
 * @param cDetails Additional details about the request
 */
func logRequest(cEndpoint, cDetails) {
	if (REQUEST_LOGGING) {
		cLogMsg = "REQUEST: " + cEndpoint
		if (!isNull(cDetails) && len(cDetails) > 0) {
			cLogMsg = cLogMsg + " - " + cDetails
		}
		logMessage([:message = cLogMsg, :level = "INFO", :color = :CYAN])
	}
}
