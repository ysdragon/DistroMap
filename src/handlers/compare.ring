/*
	DistroMap - Compare Handler
	===========================
	Handles release comparison endpoint.
*/

/**
 * Compare two product releases
 */
func handleCompareRequest() {
	metrics[:requestsTotal] = metrics[:requestsTotal] + 1
	metrics[:requestsByEndpoint][:compare] = metrics[:requestsByEndpoint][:compare] + 1
	
	cProduct1 = oServer.Match(1)
	cVersion1 = oServer.Match(2)
	cProduct2 = oServer.Match(3)
	cVersion2 = oServer.Match(4)
	
	logRequest("/compare", cProduct1 + "/" + cVersion1 + " vs " + cProduct2 + "/" + cVersion2)
	
	aResult1 = findReleaseForProductAndCodename(cProduct1, cVersion1)
	aResult2 = findReleaseForProductAndCodename(cProduct2, cVersion2)
	
	if (isNull(aResult1[:release]) || isNull(aResult2[:release])) {
		metrics[:requestsFailed] = metrics[:requestsFailed] + 1
		aErrors = []
		if (isNull(aResult1[:release])) {
			add(aErrors, cProduct1 + "/" + cVersion1 + " not found")
		}
		if (isNull(aResult2[:release])) {
			add(aErrors, cProduct2 + "/" + cVersion2 + " not found")
		}
		aError = [
			:error = "One or both releases not found",
			:details = aErrors
		]
		sendJsonResponse(aError, 404, 0)
		return
	}
	
	metrics[:requestsSuccessful] = metrics[:requestsSuccessful] + 1
	
	aResponse = [
		:comparison = [
			:release1 = [
				:product = cProduct1,
				:version = cVersion1,
				:data = aResult1[:release]
			],
			:release2 = [
				:product = cProduct2,
				:version = cVersion2,
				:data = aResult2[:release]
			],
			:analysis = compareReleases(aResult1[:release], aResult2[:release])
		]
	]
		
	sendJsonResponse(aResponse, 200, CACHE_MAX_AGE)
}

/**
 * Compare two releases and return analysis
 */
func compareReleases(aRelease1, aRelease2) {
	aAnalysis = [
		:eolComparison = "unknown",
		:ltsComparison = "unknown",
		:recommendation = ""
	]
	
	// Get EOL dates safely as strings
	cEol1 = ""
	cEol2 = ""
	if (!isNull(aRelease1[:eolFrom])) { cEol1 = "" + aRelease1[:eolFrom] }
	if (!isNull(aRelease2[:eolFrom])) { cEol2 = "" + aRelease2[:eolFrom] }
	
	// Compare EOL dates
	if (len(cEol1) > 0 && len(cEol2) > 0) {
		nCmp = strcmp(cEol1, cEol2)
		if (nCmp > 0) {
			aAnalysis[:eolComparison] = "Release 1 has longer support (EOL: " + cEol1 + " vs " + cEol2 + ")"
		elseif (nCmp < 0)
			aAnalysis[:eolComparison] = "Release 2 has longer support (EOL: " + cEol2 + " vs " + cEol1 + ")"
		else
			aAnalysis[:eolComparison] = "Both releases have the same EOL date: " + cEol1
		}
	}
	
	// Compare LTS status
	bLts1 = isTruthy(aRelease1[:isLts])
	bLts2 = isTruthy(aRelease2[:isLts])
	
	if (bLts1 && !bLts2) {
		aAnalysis[:ltsComparison] = "Only Release 1 is LTS"
	elseif (!bLts1 && bLts2)
		aAnalysis[:ltsComparison] = "Only Release 2 is LTS"
	elseif (bLts1 && bLts2)
		aAnalysis[:ltsComparison] = "Both releases are LTS"
	else
		aAnalysis[:ltsComparison] = "Neither release is LTS"
	}
	
	// Check maintained status safely
	bMaint1 = isTruthy(aRelease1[:isMaintained])
	bMaint2 = isTruthy(aRelease2[:isMaintained])
	
	// Recommendation
	if (bMaint1 && !bMaint2) {
		aAnalysis[:recommendation] = "Release 1 is recommended (still maintained)"
	elseif (!bMaint1 && bMaint2)
		aAnalysis[:recommendation] = "Release 2 is recommended (still maintained)"
	elseif (bMaint1 && bMaint2)
		if (len(cEol1) > 0 && len(cEol2) > 0 && strcmp(cEol1, cEol2) > 0) {
			aAnalysis[:recommendation] = "Release 1 is recommended (longer support period)"
		elseif (len(cEol1) > 0 && len(cEol2) > 0 && strcmp(cEol2, cEol1) > 0)
			aAnalysis[:recommendation] = "Release 2 is recommended (longer support period)"
		else
			aAnalysis[:recommendation] = "Both releases are equivalent in terms of support"
		}
	else
		aAnalysis[:recommendation] = "Neither release is currently maintained - consider upgrading"
	}
	
	return aAnalysis
}
