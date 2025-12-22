/**
 * Validates input parameters for API requests
 * @param cProductName The product name to validate
 * @param cCodename The codename to validate
 * @return true (1) if valid, false (0) otherwise
 */
func validateInput(cProductName, cCodename) {
    if (isNull(cProductName) || isNull(cCodename)) {
        return false
    }

    if (len(cProductName) = 0 || len(cCodename) = 0) {
        return false
    }

    // Check for valid characters (alphanumeric, dots, hyphens, underscores)
    if (!isValidProductName(cProductName) || !isValidCodename(cCodename)) {
        return false
    }

    return true
}

/**
 * Validates product name format
 * @param cName The product name to validate
 * @return true (1) if valid format, false (0) otherwise
 */
func isValidProductName(cName) {
    // Allow alphanumeric, dots, hyphens, underscores
    for i = 1 to len(cName)
        cChar = substr(cName, i, 1)
        if (!isalnum(cChar) && cChar != "." && cChar != "-" && cChar != "_") {
            return false
        }
    next
    return true
}

/**
 * Validates codename format
 * @param cCodename The codename to validate
 * @return true (1) if valid format, false (0) otherwise
 */
func isValidCodename(cCodename) {
    // Allow alphanumeric, dots, hyphens, underscores
    for i = 1 to len(cCodename)
        cChar = substr(cCodename, i, 1)
        if (!isalnum(cChar) && cChar != "." && cChar != "-" && cChar != "_") {
            return false
        }
    next
    return true
}