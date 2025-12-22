/*
	DistroMap - Global State
	========================
	Central state management for the application.
*/

// Stores the entire product database from the API
aProductsData = NULL

// Stores the HTTPLib server object
oServer = NULL

// Application state
appState = [
	:lastUpdateTime = 0,
	:updateCount = 0,
	:startTime = [],
	:upstreamStatus = "unknown",
	:upstreamLastCheck = ""
]

// Metrics tracking
metrics = [
	:requestsTotal = 0,
	:requestsByEndpoint = [
		:distro = 0,
		:products = 0,
		:compare = 0,
		:health = 0,
		:metrics = 0,
		:root = 0
	],
	:requestsSuccessful = 0,
	:requestsFailed = 0,
	:notFoundCount = 0,
	:fuzzyMatchCount = 0
]
