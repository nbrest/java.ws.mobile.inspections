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

# Global variables
LOG_PROCESS_TO_FILE=false
DOCKER_PORT_HTTP=7080
SERVICE="kamehouse-docker"
SERVICE_STARTUP="${HOME}/programs/kamehouse-shell/bin/kamehouse/docker/docker-run-kamehouse.sh"
DOCKER_PROFILE="prod"
DOCKER_ENVIRONMENT="ubuntu"

mainProcess() {
  PID=`netstat -ano | grep "LISTENING" | grep "${DOCKER_PORT_HTTP}" | tail -n 1`
  if [ -z "${PID}" ]; then
    log.info "${SERVICE} not running. Starting it now"
    ${SERVICE_STARTUP} -p ${DOCKER_PROFILE} -o ${DOCKER_ENVIRONMENT} &
  else
    log.info "${SERVICE} with profile ${DOCKER_PROFILE} is currently running with pid ${COL_PURPLE}${PID}"
  fi
}

parseArguments() {
  while getopts ":ho:p:" OPT; do
    case $OPT in
    ("h")
      parseHelp
      ;;
    ("o")
      DOCKER_ENVIRONMENT=$OPTARG
      ;;
    ("p")
      DOCKER_PROFILE=$OPTARG
      ;;
    (\?)
      parseInvalidArgument "$OPTARG"
      ;;
    esac
  done

  if [ "${DOCKER_ENVIRONMENT}" != "ubuntu" ] &&
    [ "${DOCKER_ENVIRONMENT}" != "pi" ]; then
    log.error "Option -o [os] has an invalid value of ${DOCKER_ENVIRONMENT}"
    printHelp
    exitProcess 1
  fi

  if [ "${DOCKER_PROFILE}" != "ci" ] &&
    [ "${DOCKER_PROFILE}" != "dev" ] &&
    [ "${DOCKER_PROFILE}" != "demo" ] &&
    [ "${DOCKER_PROFILE}" != "prod" ] &&
    [ "${DOCKER_PROFILE}" != "prod-ext" ]; then
    log.error "Option -p [profile] has an invalid value of ${DOCKER_PROFILE}"
    printHelp
    exitProcess 1
  fi
  
  if [ "${DOCKER_PROFILE}" == "ci" ]; then
    DOCKER_PORT_HTTP=15080
  fi

  if [ "${DOCKER_PROFILE}" == "demo" ]; then
    DOCKER_PORT_HTTP=12080
  fi

  if [ "${DOCKER_PROFILE}" == "dev" ]; then
    DOCKER_PORT_HTTP=6080
  fi

  if [ "${DOCKER_PROFILE}" == "prod" ]; then
    DOCKER_PORT_HTTP=7080
  fi

  if [ "${DOCKER_PROFILE}" == "prod-ext" ]; then
    DOCKER_PORT_HTTP=7080
  fi
}

printHelp() {
  echo -e ""
  echo -e "Usage: ${COL_PURPLE}${SCRIPT_NAME}${COL_NORMAL} [options]"
  echo -e ""
  echo -e "  Options:"  
  echo -e "     ${COL_BLUE}-h${COL_NORMAL} display help"
  echo -e "     ${COL_BLUE}-o (ubuntu|pi)${COL_NORMAL} default value is ubuntu"
  echo -e "     ${COL_BLUE}-p (ci|dev|demo|prod|prod-ext)${COL_NORMAL} default profile is dev"
}

main "$@"
