#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
	echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
	exit 1
fi

LOG_PROCESS_TO_FILE=true
DEFAULT_HTTPD_PORT=80
HTTPD_PORT=""

mainProcess() {
  HTTPD_PORT_PARAM=$1
  if [ -z "${HTTPD_PORT_PARAM}" ]; then
    HTTPD_PORT=${DEFAULT_HTTPD_PORT}
  else
    HTTPD_PORT=${HTTPD_PORT_PARAM}
  fi

  log.info "Searching for apache httpd process"
  netstat -ano | grep "LISTENING" | grep "\[::\]:${HTTPD_PORT}" | tail -n 1 
  HTTPD_PID=`netstat -ano | grep "LISTENING" | grep "\[::\]:${HTTPD_PORT}" | tail -n 1 | awk '{print $5}' | cut -d '/' -f 1`
  if [ -z ${HTTPD_PID} ]; then
    log.info "Apache httpd is not running"
  else
    log.info "Killing process ${COL_PURPLE}${HTTPD_PID}"
    cmd.exe "/c taskkill.exe /PID ${HTTPD_PID} /F"
  fi
}

main "$@"
