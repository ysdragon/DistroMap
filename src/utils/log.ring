load "color.ring"

/**
 * Logs a message with specified level and color
 */

func logMessage(aParams) {
    cMessage = aParams[:message]
    cLevel = aParams[:level]
    cColor = aParams[:color]
    if (isNull(cColor)) {
        switch cLevel {
            case "INFO"
                cColor = :WHITE
            case "WARN"
                cColor = :YELLOW
            case "ERROR"
                cColor = :BRIGHT_RED
            case "SUCCESS"
                cColor = :BRIGHT_GREEN
            case "DEBUG"
                cColor = :CYAN
            else
                cColor = :WHITE
        }
    }

    cTimestamp = getFormattedTimestamp()
    cLogMessage = "[" + cTimestamp + "] " + cLevel + ": " + cMessage

    ? colorText([:text = cLogMessage, :color = cColor])
}

/**
 * Gets a formatted timestamp for logging
 */
func getFormattedTimestamp() {
    date = timeList()
    year = date[19]
    month = date[10]
    day = date[6]
    hour = date[7]
    minute = date[11]
    second = date[13]
    return year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second
}