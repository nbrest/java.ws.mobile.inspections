#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
	echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
	exit 1
fi

USERHOME_WIN="${HOME}"
USERHOME_LIN="/home/nbrest"
HOST=""
HOST_FILE="${HOME}/home-synced/host"

main() {
  if ${IS_LINUX_HOST}; then
    HOSTNAME=`hostname`
    if [ "${HOSTNAME}" == "pi" ]; then
      USERHOME_LIN="/home/pi"
    fi

    if [ -f "${HOST_FILE}" ]; then
      HOST=`cat ${HOST_FILE}`
      if [ "${HOST}" == "aws" ]; then
        USERHOME_LIN="/home/ubuntu"
      fi
    fi
    echo "${USERHOME_LIN}"
  else
    echo "${USERHOME_WIN}"
  fi   
}

main "$@"
