#!/bin/bash

# Import common functions
source ${HOME}/programs/kamehouse-shell/bin/common/common-functions.sh
if [ "$?" != "0" ]; then
	echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
	exit 1
fi

LOG_PROCESS_TO_FILE=true
DEFAULT_TOMCAT_PORT=9090
TOMCAT_PORT=""

mainProcess() {
  log.info "Searching for tomcat process"
  netstat -nltp | grep ${TOMCAT_PORT} | grep java
  TOMCAT_PID=`netstat -nltp | grep ${TOMCAT_PORT} | grep java | awk '{print $7}' | cut -d '/' -f 1`
  if [ -z ${TOMCAT_PID} ]; then
    log.info "Tomcat is not running"
  else
    log.info "Killing process ${COL_PURPLE}${TOMCAT_PID}"
    kill -9 ${TOMCAT_PID}
  fi
}

parseArguments() {
  while getopts ":p:" OPT; do
    case $OPT in
    ("p")
      TOMCAT_PORT=$OPTARG
      ;;
    (\?)
      parseInvalidArgument "$OPTARG"
      ;;
    esac
  done

  if [ -z "${TOMCAT_PORT}" ]; then
    TOMCAT_PORT=${DEFAULT_TOMCAT_PORT}
  fi
}

printHelpOptions() {
  addHelpOption "-p" "tomcat port. Default ${DEFAULT_TOMCAT_PORT}"
}

main "$@"
