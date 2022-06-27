#!/bin/bash

# Execute from the root of the kamehouse git project:
# chmod a+x ./kamehouse-shell/bin/kamehouse/install-kamehouse-shell.sh
# ./kamehouse-shell/bin/kamehouse/install-kamehouse-shell.sh

DEFAULT_KAMEHOUSE_USERNAME=""

COL_BLUE="\033[1;34m"
COL_BOLD="\033[1m"
COL_CYAN="\033[1;36m"
COL_GREEN="\033[1;32m"
COL_NORMAL="\033[0;39m"
COL_PURPLE="\033[1;35m"
COL_RED="\033[1;31m"
COL_YELLOW="\033[1;33m"
COL_MESSAGE=${COL_GREEN}

KAMEHOUSE_SHELL_PATH=${HOME}/programs/kamehouse-shell
TEMP_PATH=${HOME}/temp

KAMEHOUSE_SHELL_SOURCE=`pwd`
INSTALL_SCRIPTS_ONLY=false

main() {
  parseArguments "$@"
  log.info "Installing ${COL_PURPLE}kamehouse-shell${COL_MESSAGE} to ${COL_PURPLE}${KAMEHOUSE_SHELL_PATH}"
  log.info "Using directory ${COL_PURPLE}${KAMEHOUSE_SHELL_SOURCE}${COL_MESSAGE} as the source of the scripts"
  checkSourcePath
  getDefaultKameHouseUsername
  createLogsDir
  installKameHouseShell
  updateUsername
  fixPermissions
  generateKameHouseShellPathFile
  if ! ${INSTALL_SCRIPTS_ONLY}; then
    installCred
    updateBashRc
  else
    log.info "Installing kamehouse-shell scripts only, so skipping the rest of the steps"
  fi
  log.info "Done installing ${COL_PURPLE}kamehouse-shell!"
}

checkSourcePath() {
  if [ ! -d "${KAMEHOUSE_SHELL_SOURCE}/kamehouse-shell/bin" ] || [ ! -d "${KAMEHOUSE_SHELL_SOURCE}/.git" ]; then
    log.error "This script needs to run from the root directory of a kamehouse git repository. Can't continue"
    exit 1
  fi
}

getDefaultKameHouseUsername() {
  DEFAULT_KAMEHOUSE_USERNAME=`cat Dockerfile | grep "ARG KAMEHOUSE_USERNAME=" | awk -F'=' '{print $2}'`
  if [ -z "${DEFAULT_KAMEHOUSE_USERNAME}" ]; then
    log.error "Could not set default kamehouse username from Dockerfile"
    exit 1
  fi 
}

createLogsDir() {
  mkdir -p ${HOME}/logs
}

installKameHouseShell() {
  log.info "Rebuilding shell scripts directory"
  rm -r -f ${KAMEHOUSE_SHELL_PATH}
  mkdir -p ${KAMEHOUSE_SHELL_PATH}
  cp -r -f ${KAMEHOUSE_SHELL_SOURCE}/kamehouse-shell/bin ${KAMEHOUSE_SHELL_PATH}/
}

fixPermissions() {
  log.info "Fixing permissions"
  chmod -R a+x ${KAMEHOUSE_SHELL_PATH}
}

installCred() {
  log.info "Installing credentials file"
  if [ ! -f "${HOME}/.kamehouse/.shell/.cred" ]; then
    log.info "${COL_PURPLE}${HOME}/.kamehouse/.shell/.cred${COL_MESSAGE} not found. Creating it from template"
    mkdir -p ${HOME}/.kamehouse/.shell/
    cp docker/keys/.cred ${HOME}/.kamehouse/.shell/.cred
  fi
}

updateUsername() {
  local USERNAME=`whoami`
  log.info "Updating username in kamehouse-shell scripts to ${COL_PURPLE}${USERNAME}"
  sed -i "s#USERNAME=\"\${DEFAULT_KAMEHOUSE_USERNAME}\"#USERNAME=\"${USERNAME}\"#g" "${KAMEHOUSE_SHELL_PATH}/bin/kamehouse/get-username.sh"
  sed -i "s#USERHOME_LIN=\"/home/\${DEFAULT_KAMEHOUSE_USERNAME}\"#USERHOME_LIN=\"/home/${USERNAME}\"#g" "${KAMEHOUSE_SHELL_PATH}/bin/kamehouse/get-userhome.sh"
  sed -i "s#KAMEHOUSE_USER=\"\"#KAMEHOUSE_USER=\"${USERNAME}\"#g" "${KAMEHOUSE_SHELL_PATH}/bin/lin/startup/rc-local.sh"
  sed -i "s#KAMEHOUSE_USER=\"\"#KAMEHOUSE_USER=\"${USERNAME}\"#g" "${KAMEHOUSE_SHELL_PATH}/bin/pi/startup/rc-local.sh"
  sed -i "s#DEFAULT_KAMEHOUSE_USERNAME=\"\"#DEFAULT_KAMEHOUSE_USERNAME=\"${DEFAULT_KAMEHOUSE_USERNAME}\"#g" "${KAMEHOUSE_SHELL_PATH}/bin/common/kamehouse/kamehouse-functions.sh"
}

updateBashRc() {
  log.info "Updating ${COL_PURPLE}${HOME}/.bashrc"
  if [ ! -f "${HOME}/.bashrc" ]; then
    log.info "${COL_PURPLE}${HOME}/.bashrc${COL_MESSAGE} not found. Creating one"
    echo "" > ${HOME}/.bashrc
    echo "source \${HOME}/programs/kamehouse-shell/bin/common/bashrc/bashrc.sh" >> ${HOME}/.bashrc
  else 
    cat ${HOME}/.bashrc | grep "/programs/kamehouse-shell/bin/common/bashrc/bashrc.sh" > /dev/null
    if [ "$?" != "0" ]; then
      log.info "Adding bashrc/bashrc.sh to ${COL_PURPLE}${HOME}/.bashrc"
      echo "" >> ${HOME}/.bashrc
      echo "source \${HOME}/programs/kamehouse-shell/bin/common/bashrc/bashrc.sh" >> ${HOME}/.bashrc
    else 
      log.info "${COL_PURPLE}${HOME}/.bashrc${COL_MESSAGE} already sources ${COL_PURPLE}${HOME}/programs/kamehouse-shell/bin/common/bashrc/bashrc.sh${COL_MESSAGE}. No need to update"
    fi
  fi
}

generateKameHouseShellPathFile() {
  log.info "Generating kamehouse-shell PATH file"
  local KAMEHOUSE_SHELL_CONF_PATH=${KAMEHOUSE_SHELL_PATH}/conf
  local KAMEHOUSE_SHELL_PATH_FILE=${KAMEHOUSE_SHELL_CONF_PATH}/path.conf

  mkdir -p ${KAMEHOUSE_SHELL_CONF_PATH}

  echo "# This file is auto generated by kamehouse-shell install script. Don't modify it" > ${KAMEHOUSE_SHELL_PATH_FILE}

  local KAMEHOUSE_SHELL_WIN_PATH=`getPathWithSubdirectories "${HOME}/programs/kamehouse-shell/bin" "/lin\|/pi"`
  echo "KAMEHOUSE_SHELL_WIN_PATH=${KAMEHOUSE_SHELL_WIN_PATH}" >> ${KAMEHOUSE_SHELL_PATH_FILE}

  local KAMEHOUSE_SHELL_LIN_PATH=`getPathWithSubdirectories "${HOME}/programs/kamehouse-shell/bin" "/win"`
  echo "KAMEHOUSE_SHELL_LIN_PATH=${KAMEHOUSE_SHELL_LIN_PATH}" >> ${KAMEHOUSE_SHELL_PATH_FILE}
}

###########################################################################
# IMPORTANT: If I block a path here, also block it to csv-kamehouse-shell.sh
###########################################################################
getPathWithSubdirectories() {
  local BASE_PATH=$1
  local PATHS_TO_SKIP_REGEX=$2
  if [ ! -d "${BASE_PATH}" ]; then
    return
  fi
  # List all directories
  local PATH_WITH_SUBDIRS=$(find ${BASE_PATH} -name '.*' -prune -o -type d)
  # Filter aws
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v '/aws')
  # Filter bashrc
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v /aws/bashrc) 
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v /lin/bashrc) 
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v /win/bashrc) 
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v /common/bashrc) 
  # Filter deprecated
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v /deprecated)
  # Filter sudoers
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v /lin/sudoers)
  # Filter path to skip parameter
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v -e "${PATHS_TO_SKIP_REGEX}") 
  # Filter .. directory
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | grep -v '/\..*')
  # Replace \n with :  
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | tr '\n' ':')
  # Remove last :
  PATH_WITH_SUBDIRS=$(echo "$PATH_WITH_SUBDIRS" | sed '$s/.$//')

  echo "${PATH_WITH_SUBDIRS}"
} 

log.info() {
  local ENTRY_DATE="${COL_CYAN}$(date +%Y-%m-%d' '%H:%M:%S)${COL_NORMAL}"
  local LOG_MESSAGE=$1
  echo -e "${ENTRY_DATE} - [${COL_BLUE}INFO${COL_NORMAL}] - ${COL_MESSAGE}${LOG_MESSAGE}${COL_NORMAL}"
}

log.error() {
  local ENTRY_DATE="${COL_CYAN}$(date +%Y-%m-%d' '%H:%M:%S)${COL_NORMAL}"
  local LOG_MESSAGE=$1
  echo -e "${ENTRY_DATE} - [${COL_RED}ERROR${COL_NORMAL}] - ${COL_RED}${LOG_MESSAGE}${COL_NORMAL}"
}

parseArguments() {
  while getopts ":hop" OPT; do
    case $OPT in
    ("h")
      printHelp
      exit 0
      ;;
    ("o")
      INSTALL_SCRIPTS_ONLY=true
      ;;
    ("p")
      KAMEHOUSE_SHELL_SOURCE=${HOME}/git/kamehouse
      ;;
    (\?)
      log.error "Invalid argument $OPTARG"
      exit 1
      ;;
    esac
  done
}

printHelp() {
  echo -e ""
  echo -e "Usage: ${COL_PURPLE}install-kamehouse-shell.sh${COL_NORMAL} [options]"
  echo -e ""
  echo -e "  Options:"  
  echo -e "     ${COL_BLUE}-h${COL_NORMAL} display help"
  echo -e "     ${COL_BLUE}-o${COL_NORMAL} only install kamehouse shell scripts. Don't modify the shell"
  echo -e "     ${COL_BLUE}-p${COL_NORMAL} use kamehouse git prod directory instead of current dir"
}

main "$@"
