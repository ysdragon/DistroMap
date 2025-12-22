/*
	DistroMap - Search Service
	==========================
	Handles product and release search with fuzzy matching.
*/

/**
 * Searches the in-memory database for a specific product and codename
 * Now with fuzzy matching support
 * @param cProductName The product name to search for
 * @param cCodename The codename to search for
 * @return List with :release, :fuzzyMatch, :matchedProduct keys
 */
func findReleaseForProductAndCodename(cProductName, cCodename) {
	cSearchProduct = lower(cProductName)
	cSearchCodename = lower(cCodename)

	aReturnVal = [
		:release = NULL,
		:fuzzyMatch = false,
		:matchedProduct = ""
	]

	if (!aProductsData || !aProductsData[:result]) {
		logMessage([:message = "Database not loaded or empty", :level = "WARN"])
		return aReturnVal
	}

	// Find the product (with fuzzy matching)
	aProductResult = findProductWithFuzzy(cProductName)
	
	if (isNull(aProductResult[:product])) {
		return aReturnVal
	}
	
	aTargetProduct = aProductResult[:product]
	aReturnVal[:fuzzyMatch] = aProductResult[:fuzzyMatch]
	aReturnVal[:matchedProduct] = aProductResult[:matchedProduct]

	// Find the release within that product
	if (aTargetProduct[:releases]) {
		for aRelease in aTargetProduct[:releases] {
			if (aRelease) {
				// Check codename match
				if (aRelease[:codename]) {
					if (lower(aRelease[:codename]) = cSearchCodename ||
						substr(lower(aRelease[:codename]), cSearchCodename)) {
						aReturnVal[:release] = aRelease
						return aReturnVal
					}
				}
				// Check version/name match
				if (aRelease[:name] && lower("" + aRelease[:name]) = cSearchCodename) {
					aReturnVal[:release] = aRelease
					return aReturnVal
				}
			}
		}
		
		// If no exact match, try fuzzy matching on codename
		nBestDistance = 999
		aBestRelease = NULL
		for aRelease in aTargetProduct[:releases] {
			if (aRelease && aRelease[:codename]) {
				nDistance = levenshteinDistance(cSearchCodename, lower(aRelease[:codename]))
				if (nDistance < nBestDistance && nDistance <= 2) {
					nBestDistance = nDistance
					aBestRelease = aRelease
				}
			}
		}
		
		if (!isNull(aBestRelease)) {
			aReturnVal[:release] = aBestRelease
			aReturnVal[:fuzzyMatch] = true
			return aReturnVal
		}
	}

	return aReturnVal
}

/**
 * Find a product with fuzzy matching support
 * @param cProductName The product name to search for
 * @return List with :product, :fuzzyMatch, :matchedProduct keys
 */
func findProductWithFuzzy(cProductName) {
	cSearchProduct = lower(cProductName)
	
	aResult = [
		:product = NULL,
		:fuzzyMatch = false,
		:matchedProduct = ""
	]
	
	if (!aProductsData || !aProductsData[:result]) {
		return aResult
	}
	
	// Exact match
	for aProduct in aProductsData[:result] {
		if (aProduct && aProduct[:name] && lower(aProduct[:name]) = cSearchProduct) {
			aResult[:product] = aProduct
			aResult[:matchedProduct] = aProduct[:name]
			return aResult
		}
	}
	
	// Fuzzy match using Levenshtein distance
	nBestDistance = 999
	aBestProduct = NULL
	cBestName = ""
	
	for aProduct in aProductsData[:result] {
		if (aProduct && aProduct[:name]) {
			nDistance = levenshteinDistance(cSearchProduct, lower(aProduct[:name]))
			// Accept matches with distance <= 2 (allows for small typos)
			if (nDistance < nBestDistance && nDistance <= 2) {
				nBestDistance = nDistance
				aBestProduct = aProduct
				cBestName = aProduct[:name]
			}
		}
	}
	
	if (!isNull(aBestProduct)) {
		aResult[:product] = aBestProduct
		aResult[:fuzzyMatch] = true
		aResult[:matchedProduct] = cBestName
	}
	
	return aResult
}

/**
 * Get similar product names for suggestions
 * @param cProductName The product name to find similar matches for
 * @return List of similar product names
 */
func getSimilarProducts(cProductName) {
	aSuggestions = []
	cLower = lower(cProductName)
	
	if (!aProductsData || !aProductsData[:result]) {
		return aSuggestions
	}
	
	// Find products with small Levenshtein distance
	for aProduct in aProductsData[:result] {
		if (aProduct && aProduct[:name]) {
			nDistance = levenshteinDistance(cLower, lower(aProduct[:name]))
			if (nDistance <= 3 && nDistance > 0) {
				add(aSuggestions, aProduct[:name])
			}
			// Also check if the search term is a substring
			if (substr(lower(aProduct[:name]), cLower)) {
				if (find(aSuggestions, aProduct[:name]) = 0) {
					add(aSuggestions, aProduct[:name])
				}
			}
		}
		// Limit suggestions to 5
		if (len(aSuggestions) >= 5) {
			exit
		}
	}
	
	return aSuggestions
}
