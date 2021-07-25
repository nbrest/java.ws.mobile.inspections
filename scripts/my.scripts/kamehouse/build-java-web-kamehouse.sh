#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
  exit 1
fi

# Import kamehouse functions
source ${HOME}/my.scripts/common/kamehouse/kamehouse-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing kamehouse-functions.sh\033[0;39m"
  exit 1
fi

FAST_BUILD=false
MODULE=
KAMEHOUSE_CMD_DEPLOY_PATH="${HOME}/programs"
MAVEN_COMMAND=
MAVEN_PROFILE="prod"

mainProcess() {
  buildProject
  deployKameHouseCmd
  cleanLogsInGitRepoFolder
}

buildProject() {
  log.info "Building ${COL_PURPLE}kamehouse${COL_DEFAULT_LOG} with profile ${COL_PURPLE}${MAVEN_PROFILE}${COL_DEFAULT_LOG}"
  MAVEN_COMMAND="mvn clean install -P ${MAVEN_PROFILE}"

  if ${FAST_BUILD}; then
    log.info "Executing fast build. Skipping checkstyle, findbugs and tests"
    MAVEN_COMMAND="${MAVEN_COMMAND} -Dmaven.test.skip=true -Dcheckstyle.skip=true -Dfindbugs.skip=true"
  fi

  if [ -n "${MODULE}" ]; then
    log.info "Building module ${COL_PURPLE}${MODULE}"
    MAVEN_COMMAND="${MAVEN_COMMAND} -pl :${MODULE} -am"
  else
    log.info "Building all modules"
  fi

  ${MAVEN_COMMAND}
  checkCommandStatus "$?" "An error occurred building kamehouse"
}

deployKameHouseCmd() {
  if [[ -z "${MODULE}" || "${MODULE}" == "kamehouse-cmd" ]]; then
    log.info "Deploying ${COL_PURPLE}kamehouse-cmd${COL_DEFAULT_LOG} to ${COL_PURPLE}${KAMEHOUSE_CMD_DEPLOY_PATH}${COL_DEFAULT_LOG}"
    mkdir -p ${KAMEHOUSE_CMD_DEPLOY_PATH}
    rm -r -f ${KAMEHOUSE_CMD_DEPLOY_PATH}/kamehouse-cmd
    unzip -o -q kamehouse-cmd/target/kamehouse-cmd-bundle.zip -d ${KAMEHOUSE_CMD_DEPLOY_PATH}/ 
    ls -lh ${KAMEHOUSE_CMD_DEPLOY_PATH}/kamehouse-cmd/bin/kamehouse-cmd.sh
    ls -lh ${KAMEHOUSE_CMD_DEPLOY_PATH}/kamehouse-cmd/lib/kamehouse-cmd*.jar
  fi
}

parseArguments() {
  while getopts ":fhm:p:" OPT; do
    case $OPT in
    ("f")
      FAST_BUILD=true
      ;;
    ("h")
      parseHelp
      ;;
    ("m")
      MODULE="kamehouse-$OPTARG"
      ;;
    ("p")
      local PROFILE_ARG=$OPTARG 
      PROFILE_ARG=`echo "${PROFILE_ARG}" | tr '[:upper:]' '[:lower:]'`
      
      if [ "${PROFILE_ARG}" != "prod" ] \
          && [ "${PROFILE_ARG}" != "qa" ] \
          && [ "${PROFILE_ARG}" != "dev" ]; then
        log.error "Option -p profile needs to be prod, qa or dev"
        printHelp
        exitProcess 1
      fi
            
      MAVEN_PROFILE=${PROFILE_ARG}
      ;;
    (\?)
      parseInvalidArgument "$OPTARG"
      ;;
    esac
  done
  
}

printHelp() {
  echo -e ""
  echo -e "Usage: ${COL_PURPLE}${SCRIPT_NAME}${COL_NORMAL} [options]"
  echo -e ""
  echo -e "  Options:"  
  echo -e "     ${COL_BLUE}-f${COL_NORMAL} fast build. Skip checkstyle, findbugs and tests" 
  echo -e "     ${COL_BLUE}-h${COL_NORMAL} display help" 
  echo -e "     ${COL_BLUE}-m (admin|cmd|groot|media|tennisworld|testmodule|ui|vlcrc)${COL_NORMAL} module to build"
  echo -e "     ${COL_BLUE}-p (prod|qa|dev)${COL_NORMAL} maven profile to build the project with. Default is prod if not specified"
}

main "$@"
