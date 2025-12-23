/*
	DistroMap - Products Handler
	============================
	Handles product listing endpoints.
*/

/**
 * Products list endpoint - returns all available products
 */
func handleProductsRequest() {
	incrementMetric(:requestsTotal)
	incrementEndpointMetric(:products)
	
	logRequest("/products", "")
	
	if (isNull(aProductsData) || isNull(aProductsData[:result])) {
		incrementMetric(:requestsFailed)
		aError = [:error = "Database not loaded"]
		sendJsonResponse(aError, 503, 0)
		return
	}
	
	incrementMetric(:requestsSuccessful)
	
	aProducts = []
	for aProduct in aProductsData[:result] {
		if (aProduct && aProduct[:name]) {
			aProductInfo = [
				:name = aProduct[:name],
				:releaseCount = 0
			]
			if (aProduct[:releases]) {
				aProductInfo[:releaseCount] = len(aProduct[:releases])
			}
			add(aProducts, aProductInfo)
		}
	}
	
	aResponse = [
		:count = len(aProducts),
		:products = aProducts
	]
	
	sendJsonResponse(aResponse, 200, CACHE_MAX_AGE)
}

/**
 * Get all releases for a specific product
 */
func handleProductReleasesRequest() {
	incrementMetric(:requestsTotal)
	incrementEndpointMetric(:products)
	
	cProductName = oServer.Match(1)
	logRequest("/products/{product}", cProductName)
	
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
