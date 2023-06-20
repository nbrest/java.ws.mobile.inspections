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

source ${HOME}/programs/kamehouse-shell/bin/common/kamehouse/docker-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing docker-functions.sh\033[0;39m"
  exit 1
fi

BUILD_ON_STARTUP=false
BUILD_ON_STARTUP_PARAM=""
DEBUG_MODE=false
DEBUG_MODE_PARAM=""
DOCKER_COMMAND="docker run --rm"
DOCKER_CONTROL_HOST=false
DOCKER_CONTROL_HOST_PARAM=""
DOCKER_HOST_IP=""
DOCKER_HOST_HOSTNAME=""
DOCKER_HOST_SUBNET=""
DOCKER_IMAGE_HOSTNAME=""
EXPORT_NATIVE_HTTPD=false
USE_VOLUMES=false
USE_VOLUMES_PARAM=""

mainProcess() {
  setEnvironment
  printEnv
  runDockerImage  
}

setEnvironment() {
  if ${IS_LINUX_HOST}; then
    DOCKER_HOST_OS="linux"
    IS_LINUX_DOCKER_HOST=true
  else
    DOCKER_HOST_OS="windows"
    IS_LINUX_DOCKER_HOST=false
  fi
  DOCKER_HOST_USERNAME=`whoami`
  DOCKER_HOST_IP=`getKameHouseDockerHostIp ${DOCKER_HOST_SUBNET}`
  DOCKER_HOST_HOSTNAME=`hostname`

  if [ -n "${DOCKER_HOST_HOSTNAME}" ]; then
    DOCKER_IMAGE_HOSTNAME=${DOCKER_HOST_HOSTNAME}"-docker"
    if [ -n "${DOCKER_PROFILE}" ]; then
      DOCKER_IMAGE_HOSTNAME=${DOCKER_IMAGE_HOSTNAME}"-"${DOCKER_PROFILE}
    fi
  fi
}

printEnv() {
  log.info "Environment passed to the container"
  echo ""
  log.info "BUILD_ON_STARTUP=${BUILD_ON_STARTUP}"
  log.info "DEBUG_MODE=${DEBUG_MODE}"
  log.info "DOCKER_BASE_OS=${DOCKER_ENVIRONMENT}"
  log.info "DOCKER_CONTROL_HOST=${DOCKER_CONTROL_HOST}"
  log.info "DOCKER_HOST_IP=${DOCKER_HOST_IP}"
  log.info "DOCKER_HOST_HOSTNAME=${DOCKER_HOST_HOSTNAME}"
  log.info "DOCKER_HOST_OS=${DOCKER_HOST_OS}"
  log.info "DOCKER_HOST_USERNAME=${DOCKER_HOST_USERNAME}"
  log.info "DOCKER_PORT_SSH=${DOCKER_PORT_SSH}"
  log.info "DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP}"
  log.info "DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS}"
  log.info "DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG}"
  log.info "DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT}"
  log.info "DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL}"
  log.info "EXPORT_NATIVE_HTTPD=${EXPORT_NATIVE_HTTPD}"
  log.info "IS_DOCKER_CONTAINER=${IS_DOCKER_CONTAINER}"
  log.info "IS_LINUX_DOCKER_HOST=${IS_LINUX_DOCKER_HOST}"
  log.info "DOCKER_PROFILE=${DOCKER_PROFILE}"
  log.info "USE_VOLUMES=${USE_VOLUMES}"
  echo ""
}

runDockerImage() {
  log.info "Running image nbrest/kamehouse:${DOCKER_IMAGE_TAG}"
  log.info "This temporary container will be removed when it exits"

  DOCKER_COMMAND=${DOCKER_COMMAND}"\
      --name ${DOCKER_IMAGE_HOSTNAME}-kamehouse \
      -h ${DOCKER_IMAGE_HOSTNAME} \
      --env BUILD_ON_STARTUP=${BUILD_ON_STARTUP} \
      --env DEBUG_MODE=${DEBUG_MODE} \
      --env DOCKER_BASE_OS=${DOCKER_ENVIRONMENT} \
      --env DOCKER_CONTROL_HOST=${DOCKER_CONTROL_HOST} \
      --env DOCKER_HOST_IP=${DOCKER_HOST_IP} \
      --env DOCKER_HOST_HOSTNAME=${DOCKER_HOST_HOSTNAME} \
      --env DOCKER_HOST_OS=${DOCKER_HOST_OS} \
      --env DOCKER_HOST_USERNAME=${DOCKER_HOST_USERNAME} \
      --env DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP} \
      --env DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS} \
      --env DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG} \
      --env DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT} \
      --env DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL} \
      --env DOCKER_PORT_SSH=${DOCKER_PORT_SSH} \
      --env IS_DOCKER_CONTAINER=${IS_DOCKER_CONTAINER} \
      --env IS_LINUX_DOCKER_HOST=${IS_LINUX_DOCKER_HOST} \
      --env EXPORT_NATIVE_HTTPD=${EXPORT_NATIVE_HTTPD} \
      --env DOCKER_PROFILE=${DOCKER_PROFILE} \
      --env USE_VOLUMES=${USE_VOLUMES} \
      -p ${DOCKER_PORT_SSH}:22 \
      -p ${DOCKER_PORT_HTTP}:80 \
      -p ${DOCKER_PORT_HTTPS}:443 \
      -p ${DOCKER_PORT_TOMCAT_DEBUG}:${TOMCAT_DEBUG_PORT} \
      -p ${DOCKER_PORT_TOMCAT}:${TOMCAT_PORT} \
      -p ${DOCKER_PORT_MYSQL}:3306 \
      "
  if ${EXPORT_NATIVE_HTTPD}; then
    log.info "Exporting ports 80 and 443 from the container"
    DOCKER_COMMAND=${DOCKER_COMMAND}"\
    -p 80:80 \
    -p 443:443 \
    "
  fi

  if ${USE_VOLUMES}; then
    log.info "Container data will be persisted in volumes: mysql-data-${DOCKER_PROFILE}, home-kamehouse-${DOCKER_PROFILE}, home-home-synced-${DOCKER_PROFILE}, home-ssh-${DOCKER_PROFILE}"
    DOCKER_COMMAND=${DOCKER_COMMAND}"\
    -v mysql-data-${DOCKER_PROFILE}:/var/lib/mysql \
    -v home-kamehouse-${DOCKER_PROFILE}:/home/${DOCKER_USERNAME}/.kamehouse \
    -v home-home-synced-${DOCKER_PROFILE}:/home/${DOCKER_USERNAME}/home-synced \
    -v home-ssh-${DOCKER_PROFILE}:/home/${DOCKER_USERNAME}/.ssh \
    "
  else 
    log.info "Container data will NOT be persisted in volumes"
  fi

  if [ "${DOCKER_PROFILE}" == "dev" ]; then
    local DOCKER_HOST_USERHOME=`getUserHome`
    log.info "Mounting ${DOCKER_HOST_USERHOME}/workspace-${IDE}/kamehouse to /home/${DOCKER_USERNAME}/git/kamehouse"
    DOCKER_COMMAND=${DOCKER_COMMAND}"\
    -v ${DOCKER_HOST_USERHOME}/workspace-${IDE}/kamehouse:/home/${DOCKER_USERNAME}/git/kamehouse \
    "
  fi
  
  DOCKER_COMMAND=${DOCKER_COMMAND}"\
    nbrest/kamehouse:${DOCKER_IMAGE_TAG}
  "
  
  echo ""
  log.debug "${DOCKER_COMMAND}"
  ${DOCKER_COMMAND}
}

getUserHome() {
  if ${IS_LINUX_HOST}; then
    echo ${HOME}
  else
    echo "//c/Users/${USER}"
  fi
}

buildProfile() {
  if [ "${DOCKER_PROFILE}" == "ci" ]; then
    BUILD_ON_STARTUP=true
    DEBUG_MODE=false
    DOCKER_CONTROL_HOST=false
    USE_VOLUMES=false
    EXPORT_NATIVE_HTTPD=false
  fi

  if [ "${DOCKER_PROFILE}" == "demo" ]; then
    BUILD_ON_STARTUP=true
    DEBUG_MODE=false
    DOCKER_CONTROL_HOST=false
    USE_VOLUMES=false
    EXPORT_NATIVE_HTTPD=false
  fi

  if [ "${DOCKER_PROFILE}" == "dev" ]; then
    BUILD_ON_STARTUP=false
    DEBUG_MODE=true
    DOCKER_CONTROL_HOST=false
    USE_VOLUMES=false
    EXPORT_NATIVE_HTTPD=false
  fi

  if [ "${DOCKER_PROFILE}" == "prod" ]; then
    BUILD_ON_STARTUP=true
    DEBUG_MODE=false
    DOCKER_CONTROL_HOST=true
    USE_VOLUMES=true
    EXPORT_NATIVE_HTTPD=false
  fi

  if [ "${DOCKER_PROFILE}" == "prod-ext" ]; then
    BUILD_ON_STARTUP=true
    DEBUG_MODE=false
    DOCKER_CONTROL_HOST=true
    USE_VOLUMES=true
    EXPORT_NATIVE_HTTPD=true
  fi

  if [ "${DOCKER_PROFILE}" == "tag" ]; then
    BUILD_ON_STARTUP=false
    DEBUG_MODE=false
    DOCKER_CONTROL_HOST=false
    USE_VOLUMES=false
    EXPORT_NATIVE_HTTPD=false
  fi
}

overrideDefaultValues() {
  if [ -n "${BUILD_ON_STARTUP_PARAM}" ]; then
    BUILD_ON_STARTUP=${BUILD_ON_STARTUP_PARAM}
  fi

  if [ -n "${DOCKER_CONTROL_HOST_PARAM}" ]; then
    DOCKER_CONTROL_HOST=${DOCKER_CONTROL_HOST_PARAM}
  fi

  if [ -n "${DEBUG_MODE_PARAM}" ]; then
    DEBUG_MODE=${DEBUG_MODE_PARAM}
  fi

  if [ -n "${USE_VOLUMES_PARAM}" ]; then
    USE_VOLUMES=${USE_VOLUMES_PARAM}
  fi
}

parseArguments() {
  parseIde "$@"
  parseDockerProfile "$@"
  
  while getopts ":bcdfi:p:s:v" OPT; do
    case $OPT in
    ("b")
      BUILD_ON_STARTUP_PARAM=true
      ;;
    ("c")
      DOCKER_CONTROL_HOST_PARAM=true      
      ;;
    ("d")
      DEBUG_MODE_PARAM=true      
      ;;
    ("f")
      BUILD_ON_STARTUP_PARAM=false
      ;;
    ("s")
      DOCKER_HOST_SUBNET=$OPTARG      
      ;;
    ("v")
      USE_VOLUMES_PARAM=true
      ;;
    (\?)
      parseInvalidArgument "$OPTARG"
      ;;
    esac
  done
}

setEnvFromArguments() {
  setEnvForIde
  setEnvForDockerProfile
  buildProfile
  overrideDefaultValues  
}

printHelpOptions() {
  addHelpOption "-b" "build and deploy kamehouse on startup"
  addHelpOption "-c" "control host through ssh. by default it runs standalone executing all commands within the container"
  addHelpOption "-d" "debug. start tomcat in debug mode"
  addHelpOption "-f" "fast startup. don't build and deploy"
  printIdeOption "ide workspace to use for a dev docker container. Default is ${DEFAULT_IDE}"
  printDockerProfileOption
  addHelpOption "-s" "docker subnet to determine host ip. Default: ${DOCKER_HOST_DEFAULT_SUBNET}"
  addHelpOption "-v" "use volumes to persist data"
}

printHelpFooter() {
  echo ""
  echo "Execute with '-s 192.168.56.*' for example, if the docker host's subnet ip is 192.168.56.0/24"
  echo ""
}

main "$@"
