/*
	DistroMap - Distro Handler
	==========================
	Handles distribution information endpoints.
*/

/**
 * Main handler for /distro/{product}/{codename} requests
 */
func handleDistroRequest() {
	incrementMetric(:requestsTotal)
	incrementEndpointMetric(:distro)
	
	cProductName = oServer.Match(2)
	cCodename = oServer.Match(3)

	logRequest("/distro", cProductName + "/" + cCodename)

	// Validate input parameters
	if (!validateInput(cProductName, cCodename)) {
		incrementMetric(:requestsFailed)
		aError = [
			:error = "Invalid product name or codename format.",
			:valid_format = "Product name and codename should contain only alphanumeric characters, dots, hyphens, and underscores."
		]
		sendJsonResponse(aError, 400, 0)
		return
	}

	aResult = findReleaseForProductAndCodename(cProductName, cCodename)

	if (!isNull(aResult[:release])) {
		// SUCCESS (200 OK)
		incrementMetric(:requestsSuccessful)
		if (aResult[:fuzzyMatch]) {
			incrementMetric(:fuzzyMatchCount)
		}
		aResponse = aResult[:release]
		if (aResult[:fuzzyMatch]) {
			aResponse[:_matchInfo] = [
				:fuzzyMatch = true,
				:matchedProduct = aResult[:matchedProduct],
				:originalQuery = cProductName
			]
		}
		sendJsonResponse(aResponse, 200, CACHE_MAX_AGE)
		if (DEBUG) {
			logMessage([:message = "Found release: " + cProductName + "/" + cCodename, :level = "DEBUG"])
		}
	else
		// NOT FOUND (404)
		incrementMetric(:requestsFailed)
		incrementMetric(:notFoundCount)
		
		// Get suggestions for similar products
		aSuggestions = getSimilarProducts(cProductName)
		
		aError = [
			:error = "Product '" + cProductName + "' with codename '" + cCodename + "' not found.",
			:suggestions = aSuggestions
		]
		sendJsonResponse(aError, 404, 0)
		if (DEBUG) {
			logMessage([:message = "Release not found: " + cProductName + "/" + cCodename, :level = "DEBUG"])
		}
	}
}

/**
 * Get all releases for a product via /distro/{product} path
 */
func handleAllReleasesRequest() {
	incrementMetric(:requestsTotal)
	incrementEndpointMetric(:distro)
	
	cProductName = oServer.Match(1)
	logRequest("/distro/{product}", cProductName + " (all releases)")
	
	aResult = findProductWithFuzzy(cProductName)
	
	if (!isNull(aResult[:product])) {
		incrementMetric(:requestsSuccessful)
		if (aResult[:fuzzyMatch]) {
			incrementMetric(:fuzzyMatchCount)
		}
		
		aResponse = [
			:product = aResult[:product][:name],
			:releaseCount = len(aResult[:product][:releases]),
			:releases = aResult[:product][:releases]
		]
		if (aResult[:fuzzyMatch]) {
			aResponse[:_matchInfo] = [
				:fuzzyMatch = true,
				:matchedProduct = aResult[:matchedProduct],
				:originalQuery = cProductName
			]
		}
		sendJsonResponse(aResponse, 200, CACHE_MAX_AGE)
	else
		incrementMetric(:requestsFailed)
		incrementMetric(:notFoundCount)
		
		aSuggestions = getSimilarProducts(cProductName)
		aError = [
			:error = "Product '" + cProductName + "' not found.",
			:suggestions = aSuggestions
		]
		sendJsonResponse(aError, 404, 0)
	}
}
