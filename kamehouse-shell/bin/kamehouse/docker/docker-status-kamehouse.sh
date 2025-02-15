#!/bin/bash

# Import common functions
source ${HOME}/programs/kamehouse-shell/bin/common/functions/common-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
  exit 99
fi

# Import kamehouse functions
source ${HOME}/programs/kamehouse-shell/bin/common/functions/kamehouse/kamehouse-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing kamehouse-functions.sh\033[0;39m"
  exit 99
fi

source ${HOME}/programs/kamehouse-shell/bin/common/functions/kamehouse/docker-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing docker-functions.sh\033[0;39m"
  exit 99
fi

KAMEHOUSE_SERVER="${DOCKER_SERVER}"
SKIP_KAMEHOUSE_SERVER_CHECK=false

mainProcess() {
  log.info "Checking docker status on current server ${COL_PURPLE}${HOSTNAME}"
  echo ""
  log.info "Docker containers"
  echo ""
  docker container list

  echo ""
  log.info "Docker images"
  echo ""
  docker images

  echo ""
  log.info "Docker volumes"
  echo ""
  docker volume ls

  if ! ${SKIP_KAMEHOUSE_SERVER_CHECK}; then
    kameHouseDockerContainersServerStatus
  fi
}

kameHouseDockerContainersServerStatus() {
  if [ "${KAMEHOUSE_SERVER}" != "${HOSTNAME}" ]; then
    log.info "Checking docker status on kamehouse docker containers server ${COL_PURPLE}${KAMEHOUSE_SERVER}"
    setSshParameters
    executeSshCommand
  fi
}

setSshParameters() {
  setEnvForKameHouseServer
  SSH_COMMAND="~/programs/kamehouse-shell/bin/kamehouse/docker/docker-status-kamehouse.sh"
}

parseArguments() {
  while getopts ":s" OPT; do
    case $OPT in
    ("s")
      SKIP_KAMEHOUSE_SERVER_CHECK=true
      ;;
    (\?)
      parseInvalidArgument "$OPTARG"
      ;;
    esac
  done 
}

printHelpOptions() {
  addHelpOption "-s" "skip docker server status check"
}

main "$@"
