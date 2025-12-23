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

// =============================================================================
// External Libraries
// =============================================================================
load "httplib.ring"
load "simplejson.ring"
load "libcurl.ring"
load "libuv.ring"

// =============================================================================
// Configuration
// =============================================================================
load "constants.ring"

// =============================================================================
// Core Modules
// =============================================================================
load "core/state.ring"
load "core/server.ring"
load "core/scheduler.ring"

// =============================================================================
// Utilities
// =============================================================================
load "utils/color.ring"
load "utils/log.ring"
load "utils/validate.ring"
load "utils/response.ring"
load "utils/helpers.ring"

// =============================================================================
// Services
// =============================================================================
load "services/database.ring"
load "services/search.ring"

// =============================================================================
// Request Handlers
// =============================================================================
load "handlers/root.ring"
load "handlers/distro.ring"
load "handlers/products.ring"
load "handlers/compare.ring"
load "handlers/health.ring"
load "handlers/metrics.ring"

// =============================================================================
// Main Application Entry Point
// =============================================================================

/**
 * Main application entry point
 * Initializes the application, loads data, and starts services
 */
func main() {
	appState[:startTime] = timelist()
	
	logMessage([:message = "DistroMap API v" + API_VERSION + " starting...", :level = "INFO", :color = :BRIGHT_CYAN])
	logMessage([:message = "Loading initial product database from endoflife.date...", :level = "INFO", :color = :YELLOW])

	// Perform the initial data load SYNCHRONOUSLY before starting anything else.
	refreshProductData()

	// Start the periodic update timer. This registers the timer with the libuv event loop.
	startPeriodicUpdateTimer()

	// Setup graceful shutdown signal handlers
	setupSignalHandlers()

	// Initialize mutex for metrics before starting HTTP server
	initMetricsMutex()

	// Start the HTTP server in a separate thread to avoid blocking the main thread.
	server_thread_id = new_uv_thread_t()
	uv_thread_create(server_thread_id, "startHttpServer()")
	logMessage([:message = "HTTP server thread started successfully", :level = "SUCCESS"])

	// Start the libuv event loop on the main thread. This will block and run indefinitely,
	logMessage([:message = "Starting event loop...", :level = "INFO"])
	uv_run(uv_default_loop(), UV_RUN_DEFAULT)
}
