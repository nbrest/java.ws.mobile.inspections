DOCKER_USERNAME=${DEFAULT_KAMEHOUSE_USERNAME}
IS_LINUX_DOCKER_HOST=""

DOCKER_PORT_SSH_CI=15022
DOCKER_PORT_HTTP_CI=15080
DOCKER_PORT_HTTPS_CI=15443
DOCKER_PORT_TOMCAT_DEBUG_CI=15000
DOCKER_PORT_TOMCAT_CI=15090
DOCKER_PORT_MYSQL_CI=15306

DOCKER_PORT_SSH_DEMO=12022
DOCKER_PORT_HTTP_DEMO=12080
DOCKER_PORT_HTTPS_DEMO=12443
DOCKER_PORT_TOMCAT_DEBUG_DEMO=12000
DOCKER_PORT_TOMCAT_DEMO=12090
DOCKER_PORT_MYSQL_DEMO=12306

DOCKER_PORT_SSH_DEV=6022
DOCKER_PORT_HTTP_DEV=6080
DOCKER_PORT_HTTPS_DEV=6443
DOCKER_PORT_TOMCAT_DEBUG_DEV=6000
DOCKER_PORT_TOMCAT_DEV=6090
DOCKER_PORT_MYSQL_DEV=6306

DOCKER_PORT_SSH_PROD=7022
DOCKER_PORT_HTTP_PROD=7080
DOCKER_PORT_HTTPS_PROD=7443
DOCKER_PORT_TOMCAT_DEBUG_PROD=7000
DOCKER_PORT_TOMCAT_PROD=7090
DOCKER_PORT_MYSQL_PROD=7306

DOCKER_PORT_SSH_TAG=13022
DOCKER_PORT_HTTP_TAG=13080
DOCKER_PORT_HTTPS_TAG=13443
DOCKER_PORT_TOMCAT_DEBUG_TAG=13000
DOCKER_PORT_TOMCAT_TAG=13090
DOCKER_PORT_MYSQL_TAG=13306

DOCKER_PORT_SSH=${DOCKER_PORT_SSH_DEV}
DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP_DEV}
DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS_DEV}
DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG_DEV}
DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT_DEV}
DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL_DEV}

DOCKER_PROFILES_LIST="(ci|dev|demo|prod|prod-ext|tag)"
DEFAULT_DOCKER_PROFILE="dev"
DOCKER_PROFILE="${DEFAULT_DOCKER_PROFILE}"

DEFAULT_DOCKER_OS="ubuntu"
DOCKER_ENVIRONMENT="${DEFAULT_DOCKER_OS}"

DOCKER_COMMAND=""
# When I update the base image here also update docker-setup.md
DOCKER_IMAGE_BASE="ubuntu:22.04"
DOCKER_IMAGE_TAG="latest"
DOCKER_BUILD_TAG=

# This may not give me the correct host ip address if there's another adapter with address 172.xxx.xxx.xxx
DOCKER_HOST_DEFAULT_SUBNET="172\.[0-9]\+\.[0-9]\+\.[0-9]\+"
#DOCKER_HOST_DEFAULT_SUBNET="192\.168\.56\.[0-9]\+"

# Get the ip address of the host running kamehouse in a docker container
getKameHouseDockerHostIp() {
  local DOCKER_HOST_SUBNET=$1
  if [ -z "${DOCKER_HOST_SUBNET}" ]; then
    DOCKER_HOST_SUBNET=${DOCKER_HOST_DEFAULT_SUBNET}
  fi

  if ${IS_LINUX_HOST}; then
    echo `ifconfig docker0 | grep -e "${DOCKER_HOST_SUBNET}" | grep "inet" | awk '{print $2}'`
  else
    echo `ipconfig | grep -e "${DOCKER_HOST_SUBNET}" | grep "IPv4" | awk '{print $14}'`
  fi
}

parseDockerProfile() {
  local ARGS=("$@")
  for i in "${!ARGS[@]}"; do
    case "${ARGS[i]}" in
      -p)
        DOCKER_PROFILE="${ARGS[i+1]}"
        ;;
    esac
  done
}

setEnvForDockerProfile() {
  if [ "${DOCKER_PROFILE}" != "ci" ] &&
    [ "${DOCKER_PROFILE}" != "demo" ] &&
    [ "${DOCKER_PROFILE}" != "dev" ] &&
    [ "${DOCKER_PROFILE}" != "prod" ] &&
    [ "${DOCKER_PROFILE}" != "prod-ext" ] &&
    [ "${DOCKER_PROFILE}" != "tag" ]; then
    log.error "Option -p [profile] has an invalid value of ${DOCKER_PROFILE}"
    printHelp
    exitProcess 1
  fi

  if [ "${DOCKER_PROFILE}" == "ci" ]; then
    DOCKER_PORT_SSH=${DOCKER_PORT_SSH_CI}
    DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP_CI}
    DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS_CI}
    DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG_CI}
    DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT_CI}
    DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL_CI}
  fi

  if [ "${DOCKER_PROFILE}" == "demo" ]; then
    DOCKER_PORT_SSH=${DOCKER_PORT_SSH_DEMO}
    DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP_DEMO}
    DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS_DEMO}
    DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG_DEMO}
    DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT_DEMO}
    DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL_DEMO}
  fi

  if [ "${DOCKER_PROFILE}" == "dev" ]; then
    DOCKER_PORT_SSH=${DOCKER_PORT_SSH_DEV}
    DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP_DEV}
    DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS_DEV}
    DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG_DEV}
    DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT_DEV}
    DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL_DEV}
  fi

  if [ "${DOCKER_PROFILE}" == "prod" ]; then
    DOCKER_PORT_SSH=${DOCKER_PORT_SSH_PROD}
    DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP_PROD}
    DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS_PROD}
    DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG_PROD}
    DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT_PROD}
    DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL_PROD}
  fi

  if [ "${DOCKER_PROFILE}" == "prod-ext" ]; then
    DOCKER_PORT_SSH=${DOCKER_PORT_SSH_PROD}
    DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP_PROD}
    DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS_PROD}
    DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG_PROD}
    DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT_PROD}
    DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL_PROD}
  fi 

  if [ "${DOCKER_PROFILE}" == "tag" ]; then
    DOCKER_PORT_SSH=${DOCKER_PORT_SSH_TAG}
    DOCKER_PORT_HTTP=${DOCKER_PORT_HTTP_TAG}
    DOCKER_PORT_HTTPS=${DOCKER_PORT_HTTPS_TAG}
    DOCKER_PORT_TOMCAT_DEBUG=${DOCKER_PORT_TOMCAT_DEBUG_TAG}
    DOCKER_PORT_TOMCAT=${DOCKER_PORT_TOMCAT_TAG}
    DOCKER_PORT_MYSQL=${DOCKER_PORT_MYSQL_TAG}
  fi
}

printDockerProfileOption() {
  addHelpOption "-p ${DOCKER_PROFILES_LIST}" "default profile is ${DEFAULT_DOCKER_PROFILE}"
}
