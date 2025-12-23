/*
	DistroMap - Database Service
	============================
	Handles data fetching and caching from endoflife.date API.
*/

/**
 * Fetches data from the external API and updates the global variable
 * @return true (1) if successful, false (0) otherwise
 */
func refreshProductData() {
	try {
		if (!isNull(aProductsData)) {
			logMessage([:message = "Refreshing product database...", :level = "INFO", :color = :YELLOW])
		}

		apiUrl = API_BASE_URL
		curl = curl_easy_init()

		if (isNull(curl)) {
			logMessage([:message = "ERROR: Failed to initialize curl", :level = "ERROR", :color = :BRIGHT_RED])
			return false
		}

		curl_easy_setopt(curl, CURLOPT_URL, apiUrl)
		curl_easy_setopt(curl, CURLOPT_USERAGENT, USER_AGENT)
		curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1)
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, SSL_VERIFY_PEER)
		curl_easy_setopt(curl, CURLOPT_TIMEOUT, API_REQUEST_TIMEOUT)
		curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, API_CONNECT_TIMEOUT)

		cResponseBody = curl_easy_perform_silent(curl)
		nStatus = curl_getResponseCode(curl)

		if (nStatus = 200) {
			aNewProductsData = json_decode(cResponseBody)

			if (isNull(aNewProductsData)) {
				logMessage([:message = "ERROR: Failed to decode JSON response", :level = "ERROR", :color = :BRIGHT_RED])
				curl_easy_cleanup(curl)
				return false
			}

			aProductsData = aNewProductsData
			appState[:lastUpdateTime] = getFormattedTimestamp()
			appState[:updateCount] = appState[:updateCount] + 1

			if (appState[:updateCount] = 1) {
				logMessage([:message = "Database loaded successfully.", :level = "SUCCESS", :color = :BRIGHT_GREEN])
			else
				logMessage([:message = "Database refreshed successfully.", :level = "SUCCESS", :color = :BRIGHT_GREEN])
			}

			curl_easy_cleanup(curl)
			return true
		else
			logMessage([:message = "ERROR: Failed to refresh database. HTTP Status: " + nStatus, :level = "ERROR", :color = :BRIGHT_RED])
			curl_easy_cleanup(curl)
			return false
		}
	catch
		logMessage([:message = "ERROR: Exception during database refresh: " + cCatchError, :level = "ERROR", :color = :BRIGHT_RED])
		return false
	}
}
