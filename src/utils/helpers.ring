/*
	DistroMap - Helper Utilities
	============================
	General helper functions used across the application.
*/

/**
 * Calculate Levenshtein distance between two strings
 * @param s1 First string
 * @param s2 Second string
 * @return Integer distance (number of edits needed)
 */
func levenshteinDistance(s1, s2) {
	n1 = len(s1)
	n2 = len(s2)
	
	// Handle empty strings
	if (n1 = 0) { return n2 }
	if (n2 = 0) { return n1 }
	
	// Ensure s1 is the shorter string
	if (n1 > n2) {
		cTemp = s1
		s1 = s2
		s2 = cTemp
		nTemp = n1
		n1 = n2
		n2 = nTemp
	}
	
	// Only need two rows: previous and current
	prevRow = list(n1 + 1)
	currRow = list(n1 + 1)
	
	// Initialize first row
	for i = 1 to n1 + 1 {
		prevRow[i] = i - 1
	}
	
	// Process each character of s2
	for j = 1 to n2 {
		currRow[1] = j
		
		for i = 1 to n1 {
			cost = 1
			if (substr(s1, i, 1) = substr(s2, j, 1)) {
				cost = 0
			}
			
			deletion = prevRow[i + 1] + 1
			insertion = currRow[i] + 1
			substitution = prevRow[i] + cost
			
			currRow[i + 1] = minOfThree(deletion, insertion, substitution)
		}
		
		// Swap rows
		tempRow = prevRow
		prevRow = currRow
		currRow = tempRow
	}
	
	return prevRow[n1 + 1]
}

/**
 * Returns the minimum of three numbers
 * @param a First number
 * @param b Second number
 * @param c Third number
 * @return The minimum value
 */
func minOfThree(a, b, c) {
	nMin = a
	if (b < nMin) { nMin = b }
	if (c < nMin) { nMin = c }
	return nMin
}

/**
 * Returns the minimum value from a list of numbers
 * @param aList List of numbers
 * @return The minimum value
 */
func minVal(aList) {
	if (len(aList) = 0) { return 0 }
	nMin = aList[1]
	for i = 2 to len(aList) {
		if (aList[i] < nMin) {
			nMin = aList[i]
		}
	}
	return nMin
}

/**
 * Check if a value is truthy (handles strings, numbers, nulls safely)
 * @param val The value to check
 * @return true (1) if truthy, false (0) otherwise
 */
func isTruthy(val) {
	if (isNull(val)) { return false }
	if (isNumber(val)) { return val != 0 }
	if (isString(val)) {
		cLower = lower(val)
		if (cLower = "true" || cLower = "1" || cLower = "yes") { return true }
		return false
	}
	return false
}

/**
 * Convert timelist() to total seconds (for comparison/difference calculation)
 * Uses day of year + hour + minute + second for accurate uptime
 * @param aTime The timelist() array
 * @return Total seconds as integer
 */
func timelistToSeconds(aTime) {
	nDayOfYear = number(aTime[9])
	nHour = number(aTime[7])
	nMinute = number(aTime[11])
	nSecond = number(aTime[13])
	nYear = number(aTime[19])
	
	// Calculate total seconds: (year * 365 * 24 * 3600) + (dayOfYear * 24 * 3600) + (hour * 3600) + (minute * 60) + second
	return (nYear * 365 * 24 * 3600) + (nDayOfYear * 24 * 3600) + (nHour * 3600) + (nMinute * 60) + nSecond
}

/**
 * Calculate uptime in seconds from start time
 * @return Uptime in seconds
 */
func getUptimeSeconds() {
	nStartSeconds = timelistToSeconds(appState[:startTime])
	nCurrentSeconds = timelistToSeconds(timelist())
	return nCurrentSeconds - nStartSeconds
}

/**
 * Get product count from database with null safety
 * @return Number of products, or 0 if database not loaded
 */
func getProductCount() {
	if (isNull(aProductsData)) { return 0 }
	if (isNull(aProductsData[:result])) { return 0 }
	return len(aProductsData[:result])
}

/**
 * Check if database is loaded and has data
 * @return true if database is ready, false otherwise
 */
func isDatabaseLoaded() {
	return !isNull(aProductsData) && !isNull(aProductsData[:result])
}
