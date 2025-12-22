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
	
	if (n1 = 0) { return n2 }
	if (n2 = 0) { return n1 }
	
	// Create distance matrix
	d = list(n1 + 1)
	for i = 1 to n1 + 1 {
		d[i] = list(n2 + 1)
		for j = 1 to n2 + 1 {
			d[i][j] = 0
		}
	}
	
	// Initialize first column
	for i = 1 to n1 + 1 {
		d[i][1] = i - 1
	}
	
	// Initialize first row
	for j = 1 to n2 + 1 {
		d[1][j] = j - 1
	}
	
	// Fill in the rest
	for i = 2 to n1 + 1 {
		for j = 2 to n2 + 1 {
			cost = 1
			if (substr(s1, i - 1, 1) = substr(s2, j - 1, 1)) {
				cost = 0
			}
			
			deletion = d[i - 1][j] + 1
			insertion = d[i][j - 1] + 1
			substitution = d[i - 1][j - 1] + cost
			
			d[i][j] = minVal([deletion, insertion, substitution])
		}
	}
	
	return d[n1 + 1][n2 + 1]
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
