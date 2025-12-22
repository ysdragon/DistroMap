/*
	DistroMap - Products Handler
	============================
	Handles product listing endpoints.
*/

/**
 * Products list endpoint - returns all available products
 */
func handleProductsRequest() {
	metrics[:requestsTotal] = metrics[:requestsTotal] + 1
	metrics[:requestsByEndpoint][:products] = metrics[:requestsByEndpoint][:products] + 1
	
	logRequest("/products", "")
	
	if (isNull(aProductsData) || isNull(aProductsData[:result])) {
		metrics[:requestsFailed] = metrics[:requestsFailed] + 1
		aError = [:error = "Database not loaded"]
		sendJsonResponse(aError, 503, 0)
		return
	}
	
	metrics[:requestsSuccessful] = metrics[:requestsSuccessful] + 1
	
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
	metrics[:requestsTotal] = metrics[:requestsTotal] + 1
	metrics[:requestsByEndpoint][:products] = metrics[:requestsByEndpoint][:products] + 1
	
	cProductName = oServer.Match(1)
	logRequest("/products/{product}", cProductName)
	
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
