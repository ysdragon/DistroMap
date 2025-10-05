/*
 ============================================================================
 DistroMap API
 ============

 A quick little API that looks up Linux distro versions.
 You give it a product and a codename, like /distro/ubuntu/noble,
 and it gives you back the version number/Distro Info.

 Author: Youssef Saeed (ysdragon) - <youssefelkholey@gmail.com>
 ============================================================================
 */

load "constants.ring"
load "httplib.ring"
load "simplejson.ring"
load "libcurl.ring"
load "libuv.ring"
load "utils/log.ring"
load "utils/validate.ring"

/*
	Global Variables
*/

// Stores the entire product database from the API
aProductsData = NULL
// Stores the HTTPLib server object
oServer = NULL
// Application state
appState = [
	:lastUpdateTime = 0,
	:updateCount = 0
]

/*
	Main Application Entry Point
*/

/**
 * Main application entry point
 * Initializes the application, loads data, and starts services
 */
func main() {
	logMessage([:message = "DistroMap API v" + API_VERSION + " starting...", :level = "INFO", :color = :BRIGHT_CYAN])
	logMessage([:message = "Loading initial product database from endoflife.date...", :level = "INFO", :color = :YELLOW])

	// Perform the initial data load SYNCHRONOUSLY before starting anything else.
	refreshProductData()

	// Start the periodic update timer. This registers the timer with the libuv event loop.
	startPeriodicUpdateTimer()

	// Start the HTTP server in a separate thread to avoid blocking the main thread.
	server_thread_id = new_uv_thread_t()
	uv_thread_create(server_thread_id, "startHttpServer()")
	logMessage([:message = "HTTP server thread started successfully", :level = "SUCCESS"])

	// Start the libuv event loop on the main thread. This will block and run indefinitely,
	logMessage([:message = "Starting event loop...", :level = "INFO"])
	uv_run(uv_default_loop(), UV_RUN_DEFAULT)
}

/* 
	HTTP Server and Request Handling
*/

/**
 * This function runs in a background thread and contains the blocking server.
 */
func startHttpServer() {
	logMessage([:message = "DistroMap API is now listening on " + SERVER_HOST + ":" + SERVER_PORT, :level = "SUCCESS", :color = :BRIGHT_GREEN])
	logMessage([:message = "Try: curl http://" + SERVER_HOST + ":" + SERVER_PORT + "/distro/ubuntu/noble", :level = "INFO", :color = :CYAN])
	logMessage([:message = "Health check: curl http://" + SERVER_HOST + ":" + SERVER_PORT + "/health", :level = "INFO", :color = :CYAN])

	oServer = new Server {
		shareFolder("src/public/assets")
		route(:Get, "/", :handleRootRequest)
		route(:Get, "(/distro/([a-zA-Z0-9._-]+)/([a-zA-Z0-9._-]+))", :handleDistroRequest)
		route(:Get, "/health", :handleHealthCheck)
		listen(SERVER_HOST, SERVER_PORT)
	}
}

/**
 * Main handler for API requests
 */
func handleDistroRequest() {
	cProductName = oServer.Match(2)
	cCodename = oServer.Match(3)

	if (DEBUG) {
		logMessage([:message = "Request: " + cProductName + "/" + cCodename, :level = "DEBUG"])
	}

	// Validate input parameters
	if (!validateInput(cProductName, cCodename)) {
		aError = [
			:error = "Invalid product name or codename format.",
			:valid_format = "Product name and codename should contain only alphanumeric characters, dots, hyphens, and underscores."
		]
		cErrorResponse = json_encode(aError)
		oServer.setStatus(400)
		oServer.setContent(cErrorResponse, "application/json")
		return
	}

	aResult = findReleaseForProductAndCodename(cProductName, cCodename)

	if (!isNull(aResult)) {
		// SUCCESS (200 OK)
		aResponse = aResult
		cJsonResponse = json_encode(aResponse)
		oServer.setStatus(200)
		oServer.setContent(cJsonResponse, "application/json")
		if (DEBUG) {
			logMessage([:message = "Found release: " + cProductName + "/" + cCodename, :level = "DEBUG"])
		}
	else
		// NOT FOUND (404)
		aError = [
			:error = "Product '" + cProductName + "' with codename '" + cCodename + "' not found.",
			:suggestions = "Check product name and codename spelling, or try a different version."
		]
		cErrorResponse = json_encode(aError)
		oServer.setStatus(404)
		oServer.setContent(cErrorResponse, "application/json")
		if (DEBUG) {
			logMessage([:message = "Release not found: " + cProductName + "/" + cCodename, :level = "DEBUG"])
		}
	}
}

/**
 * Root endpoint - serves HTML page
 */
func handleRootRequest() {
	cHtmlContent = read("src/public/index.html")
	cHtmlContent = substr(cHtmlContent, "{{API_VERSION}}", API_VERSION)
	cHtmlContent = substr(cHtmlContent, "{{RING_VERSION}}", version(true))
	oServer.setStatus(200)
	oServer.setContent(cHtmlContent, "text/html")
}

/**
 * Health check endpoint
 */
func handleHealthCheck() {
	aHealth = [
		:status = "healthy",
		:version = API_VERSION,
		:timestamp = getFormattedTimestamp(),
		:database = [
			:loaded = !isNull(aProductsData),
			:product_count = len(aProductsData[:result]),
			:last_update = appState[:lastUpdateTime],
			:update_count = appState[:updateCount]
		]
	]

	cHealthResponse = json_encode(aHealth)
	oServer.setStatus(200)
	oServer.setContent(cHealthResponse, "application/json")
}

/*
	Database and Search Functions
*/

/**
 * Searches the in-memory database for a specific product and codename
 * @param cProductName The product name to search for
 * @param cCodename The codename to search for
 * @return Release information or NULL if not found
 */
func findReleaseForProductAndCodename(cProductName, cCodename) {
	cSearchProduct = lower(cProductName)
	cSearchCodename = lower(cCodename)

	if (!aProductsData || !aProductsData[:result]) {
		logMessage([:message = "Database not loaded or empty", :level = "WARN"])
		return NULL
	}

	// Find the product first
	aTargetProduct = NULL
	for aProduct in aProductsData[:result] {
		if (aProduct && aProduct[:name] && lower(aProduct[:name]) = cSearchProduct) {
			aTargetProduct = aProduct
			exit
		}
	}

	if (isNull(aTargetProduct)) {
		return NULL
	}

	// Find the release within that product
	if (aTargetProduct[:releases]) {
		for aRelease in aTargetProduct[:releases] {
			if (aRelease && aRelease[:codename]) {
				// Check for exact match or partial match
				if (lower(aRelease[:codename]) = cSearchCodename ||
					substr(lower(aRelease[:codename]), cSearchCodename) ||
					(aRelease[:name] && lower(aRelease[:name]) = cSearchCodename)) {
					return aRelease
				}
			}
		}
	}

	return NULL
}

/**
 * Fetches data from the external API and updates the global variable
 * @return true if successful, false otherwise
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
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, false)

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

/*
	Timer and Threading Functions
*/

/**
 * Callback function executed by the libuv timer
 */
func databaseUpdateThread() {
	logMessage([:message = "Running scheduled database update...", :level = "INFO", :color = :CYAN])
	refreshProductData()
}

/**
 * Starts the libuv timer for periodic database updates
 */
func startPeriodicUpdateTimer() {
	timer = new_uv_timer_t()
	uv_timer_init(uv_default_loop(), timer)

	// Start the timer - first run is in UPDATE_INTERVAL_MS, then repeats
	uv_timer_start(timer, "databaseUpdateThread()", UPDATE_INTERVAL_MS, UPDATE_INTERVAL_MS)

	logMessage([:message = "Periodic update timer started (every " + UPDATE_INTERVAL + " hours).", :level = "INFO", :color = :BRIGHT_CYAN])
}