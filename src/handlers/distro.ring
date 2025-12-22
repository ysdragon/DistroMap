/*
	DistroMap - Distro Handler
	==========================
	Handles distribution information endpoints.
*/

/**
 * Main handler for /distro/{product}/{codename} requests
 */
func handleDistroRequest() {
	metrics[:requestsTotal] = metrics[:requestsTotal] + 1
	metrics[:requestsByEndpoint][:distro] = metrics[:requestsByEndpoint][:distro] + 1
	
	cProductName = oServer.Match(2)
	cCodename = oServer.Match(3)

	logRequest("/distro", cProductName + "/" + cCodename)

	// Validate input parameters
	if (!validateInput(cProductName, cCodename)) {
		metrics[:requestsFailed] = metrics[:requestsFailed] + 1
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
		metrics[:requestsSuccessful] = metrics[:requestsSuccessful] + 1
		if (aResult[:fuzzyMatch]) {
			metrics[:fuzzyMatchCount] = metrics[:fuzzyMatchCount] + 1
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
		metrics[:requestsFailed] = metrics[:requestsFailed] + 1
		metrics[:notFoundCount] = metrics[:notFoundCount] + 1
		
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
	metrics[:requestsTotal] = metrics[:requestsTotal] + 1
	metrics[:requestsByEndpoint][:distro] = metrics[:requestsByEndpoint][:distro] + 1
	
	cProductName = oServer.Match(1)
	logRequest("/distro/{product}", cProductName + " (all releases)")
	
	aResult = findProductWithFuzzy(cProductName)
	
	if (!isNull(aResult[:product])) {
		metrics[:requestsSuccessful] = metrics[:requestsSuccessful] + 1
		if (aResult[:fuzzyMatch]) {
			metrics[:fuzzyMatchCount] = metrics[:fuzzyMatchCount] + 1
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
		metrics[:requestsFailed] = metrics[:requestsFailed] + 1
		metrics[:notFoundCount] = metrics[:notFoundCount] + 1
		
		aSuggestions = getSimilarProducts(cProductName)
		aError = [
			:error = "Product '" + cProductName + "' not found.",
			:suggestions = aSuggestions
		]
		sendJsonResponse(aError, 404, 0)
	}
}
