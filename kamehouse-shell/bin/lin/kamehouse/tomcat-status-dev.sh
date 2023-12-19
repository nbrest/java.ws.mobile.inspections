#!/bin/bash

# Import common functions
source ${HOME}/programs/kamehouse-shell/bin/common/common-functions.sh
if [ "$?" != "0" ]; then
	echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
	exit 1
fi

# Import kamehouse functions
source ${HOME}/programs/kamehouse-shell/bin/common/kamehouse/kamehouse-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing kamehouse-functions.sh\033[0;39m"
  exit 1
fi

LOG_PROCESS_TO_FILE=true
TOMCAT_PORT=${DEFAULT_TOMCAT_DEV_PORT}

mainProcess() {
  log.info "Searching for tomcat process"
  netstat -nltp | grep ":${TOMCAT_PORT} " | grep java
  TOMCAT_PID=`netstat -nltp | grep ":${TOMCAT_PORT} " | grep java | awk '{print $7}' | cut -d '/' -f 1`
  if [ -z "${TOMCAT_PID}" ]; then
    log.info "Tomcat is not running"
  else
    log.info "Tomcat is currently running with pid ${COL_PURPLE}${TOMCAT_PID}${COL_DEFAULT_LOG} on port ${COL_PURPLE}${TOMCAT_PORT}"
  fi
}

parseArguments() {
  parseTomcatPort "$@"
}

setEnvFromArguments() {
  setEnvForTomcatPort
}

printHelpOptions() {
  printTomcatPortOption
}

main "$@"
