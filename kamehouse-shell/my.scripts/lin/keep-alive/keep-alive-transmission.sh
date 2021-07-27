#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
  exit 1
fi

# Global variables
LOG_PROCESS_TO_FILE=true
PORT=9091
SERVICE="transmission"
SERVICE_STARTUP="${HOME}/my.scripts/lin/transmission/transmission-start.sh"

mainProcess() {
  PID=`sudo netstat -nltp | grep ${PORT} | awk '{print $7}' | cut -d '/' -f 1`
  if [ -z ${PID} ]; then
    log.info "${SERVICE} is not running. Starting it now"
    ${SERVICE_STARTUP} &
  else
    log.info "${SERVICE} is currently running with pid ${COL_PURPLE}${PID}"
  fi
}

main "$@"
