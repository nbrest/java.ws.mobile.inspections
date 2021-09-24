#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
	echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
	exit 1
fi

LOG_PROCESS_TO_FILE=true
DEFAULT_TOMCAT_PORT=9090
TOMCAT_PORT=""

mainProcess() {
  TOMCAT_PORT_PARAM=$1
  if [ -z "${TOMCAT_PORT_PARAM}" ]; then
    TOMCAT_PORT=${DEFAULT_TOMCAT_PORT}
  else
    TOMCAT_PORT=${TOMCAT_PORT_PARAM}
  fi

  log.info "Searching for tomcat process"
  USERNAME=`${HOME}/my.scripts/kamehouse/get-username.sh`  
  sudo su - ${USERNAME} -c "netstat -nltp | grep ${TOMCAT_PORT} | grep java"
  TOMCAT_PID=`sudo su - ${USERNAME} -c "netstat -nltp | grep ${TOMCAT_PORT} | grep java" | awk '{print $7}' | cut -d '/' -f 1`
  if [ -z ${TOMCAT_PID} ]; then
    log.info "Tomcat is not running"
  else
    log.info "Tomcat is currently running with pid ${COL_PURPLE}${TOMCAT_PID}${COL_DEFAULT_LOG} on port ${COL_PURPLE}${TOMCAT_PORT}"
  fi
}

main "$@"
