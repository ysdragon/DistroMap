/*
	DistroMap - Scheduler
	=====================
	Timer and signal handling for periodic updates and graceful shutdown.
*/

/**
 * Setup signal handlers for graceful shutdown
 */
func setupSignalHandlers() {
	// Create signal handlers for SIGINT and SIGTERM
	sigint_handle = new_uv_signal_t()
	sigterm_handle = new_uv_signal_t()
	
	uv_signal_init(uv_default_loop(), sigint_handle)
	uv_signal_init(uv_default_loop(), sigterm_handle)
	
	uv_signal_start(sigint_handle, "handleShutdownSignal()", 2)   // SIGINT
	uv_signal_start(sigterm_handle, "handleShutdownSignal()", 15) // SIGTERM
	
	logMessage([:message = "Signal handlers registered for graceful shutdown", :level = "INFO"])
}

/**
 * Handle shutdown signals (SIGINT, SIGTERM)
 */
func handleShutdownSignal() {
	logMessage([:message = "Shutdown signal received, cleaning up...", :level = "WARN", :color = :YELLOW])
	
	// Log final metrics
	logMessage([:message = "Final metrics - Total requests: " + metrics[:requestsTotal] + 
		", Successful: " + metrics[:requestsSuccessful] + 
		", Failed: " + metrics[:requestsFailed], :level = "INFO"])
	
	logMessage([:message = "DistroMap API shutting down gracefully", :level = "INFO", :color = :CYAN])
	
	// Stop the event loop
	uv_stop(uv_default_loop())
}

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
