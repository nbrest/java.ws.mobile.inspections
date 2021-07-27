#######################################################################
# This file should be imported through common-functions, not directly #
#######################################################################
# Log functions to log events to the console with a more robust framework than just echoing.

# Default color used in logs. Use this variable to return to default color if
# I change the color of some words in the log entry.
COL_DEFAULT_LOG=${COL_GREEN}

# Log an event to the console passing log level and the message as arguments.
# DON'T use this function directly. Use log.info, log.debug, log.warn, log.error, log.trace functions
log() {
  local LEVEL=$1
  # convert log level to upper case
  LEVEL=`echo "${LEVEL}" | tr '[:lower:]' '[:upper:]'`
  local MESSAGE=$2
  # convert \n to literal '\n' in message string so it doesnt take \n as new line. For example in C:\Users\nicolas.brest
  MESSAGE=${MESSAGE//\\\n/\\\\n}
  local ENTRY_DATE="${COL_CYAN}$(date +%Y-%m-%d' '%H:%M:%S)${COL_NORMAL}"

  if [ "${LEVEL}" == "INFO" ]; then
    LEVEL="${COL_BLUE}${LEVEL}${COL_NORMAL}"
    MESSAGE="${COL_DEFAULT_LOG}${MESSAGE}${COL_NORMAL}"
  fi

  if [ "${LEVEL}" == "DEBUG" ]; then
    LEVEL="${COL_GREEN}${LEVEL}${COL_NORMAL}"
    MESSAGE="${COL_DEFAULT_LOG}${MESSAGE}${COL_NORMAL}"
  fi

  if [ "${LEVEL}" == "TRACE" ]; then
    LEVEL="${COL_CYAN}${LEVEL}${COL_NORMAL}"
    MESSAGE="${COL_DEFAULT_LOG}${MESSAGE}${COL_NORMAL}"
  fi

  if [ "${LEVEL}" == "WARN" ]; then
    LEVEL="${COL_YELLOW}${LEVEL}${COL_NORMAL}"
    MESSAGE="${COL_DEFAULT_LOG}${MESSAGE}${COL_NORMAL}"
  fi

  if [ "${LEVEL}" == "ERROR" ]; then
    LEVEL="${COL_RED}${LEVEL}${COL_NORMAL}"
    MESSAGE="${COL_RED}${MESSAGE}${COL_NORMAL}"
  fi

  echo -e "${ENTRY_DATE} - [${LEVEL}] - ${MESSAGE}"
}

# Log info
log.info() {
  log "INFO" "$1"
}

# Log debug
log.debug() {
  log "DEBUG" "$1"
}

# Log trace
log.trace() {
  log "TRACE" "$1"
}

# Log warn
log.warn() {
  log "WARN" "$1"
}

# Log error
log.error() {
  log "ERROR" "$1" 
}

# Log standard start of the script
logStart() {
  log.info "Started executing ${COL_PURPLE}${SCRIPT_NAME}${COL_DEFAULT_LOG} with command line arguments ${COL_PURPLE}\"${CMD_ARGUMENTS}\"${COL_DEFAULT_LOG}"
}

# Log standard finish of process
logFinish() {
  log.info "Finished executing ${COL_PURPLE}${SCRIPT_NAME}${COL_DEFAULT_LOG} with command line arguments ${COL_PURPLE}\"${CMD_ARGUMENTS}\"${COL_DEFAULT_LOG} successfully."
}
