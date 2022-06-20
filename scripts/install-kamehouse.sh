#!/bin/bash

# Execute this script with: 
# chmod a+x install-kamehouse.sh ; ./install-kamehouse.sh

COL_BLUE="\033[1;34m"
COL_BOLD="\033[1m"
COL_CYAN="\033[1;36m"
COL_GREEN="\033[1;32m"
COL_NORMAL="\033[0;39m"
COL_PURPLE="\033[1;35m"
COL_RED="\033[1;31m"
COL_YELLOW="\033[1;33m"
COL_MESSAGE=${COL_GREEN}

KAMEHOUSE_SHELL_ONLY=false

main() {
  parseArguments "$@"
  log.info "Installing ${COL_PURPLE}kamehouse"
  gitCloneKameHouse
  checkPath
  installKameHouseShellStandalone
  if ${KAMEHOUSE_SHELL_ONLY}; then
    log.info "Finished installing ${COL_PURPLE}kamehouse-shell${COL_MESSAGE} standalone. Running with -s so skipping the rest"
    exit 0
  fi
  buildKameHouseConfigDir
  deployKameHouse
  log.info "Finished installing ${COL_PURPLE}kamehouse"
}

gitCloneKameHouse() {
  log.info "Cloning kamehouse git repository into ${HOME}/git/kamehouse"
  mkdir -p ${HOME}/git
  cd ${HOME}/git

  if [ ! -d "./kamehouse" ]; then
    git clone https://github.com/nbrest/kamehouse.git
  else
    log.info "kamehouse repository already exists"
  fi

  cd kamehouse
  git checkout dev
  git pull origin dev
}

checkPath() {
  if [ ! -d "./kamehouse-shell/bin" ] || [ ! -d "./.git" ]; then
    log.error "This script needs to run from the root directory of a kamehouse git repository. Can't continue"
    exit 1
  fi
}

installKameHouseShellStandalone() {
  chmod a+x kamehouse-shell/bin/kamehouse/kamehouse-shell-install.sh
  ./kamehouse-shell/bin/kamehouse/kamehouse-shell-install.sh -s
}

buildKameHouseConfigDir() {
  log.info "Building kamehouse config dirs"
  mkdir -p ${HOME}/logs
  mkdir -p ${HOME}/.kamehouse/.shell
  mkdir -p ${HOME}/home-synced/.kamehouse/keys

  if [ ! -f "${HOME}/.kamehouse/.shell/.cred" ]; then
    log.info ".kamehouse/.shell/.cred file doesn't exist, creating one from the sample"
    cp -v docker/keys/.cred ${HOME}/.kamehouse/.shell/
  else
    log.info ".kamehouse/.shell/.cred file already exists. skipping"
  fi

  if [ ! -f "${HOME}/.kamehouse/.unlock.screen.pwd.enc" ]; then
    log.info ".kamehouse/.unlock.screen.pwd.enc file doesn't exist, creating one from the sample"
    cp -v docker/keys/.unlock.screen.pwd.enc ${HOME}/.kamehouse/
  else
    log.info ".kamehouse/.unlock.screen.pwd.enc file already exists. skipping"
  fi

  if [ ! -f "${HOME}/.kamehouse/.vnc.server.pwd.enc" ]; then
    log.info ".kamehouse/.vnc.server.pwd.enc file doesn't exist, creating one from the sample"
    cp -v docker/keys/.vnc.server.pwd.enc ${HOME}/.kamehouse/
  else
    log.info ".kamehouse/.vnc.server.pwd.enc file already exists. skipping"
  fi

  if [ ! -f "${HOME}/home-synced/.kamehouse/integration-test-cred.enc" ]; then
    log.info "home-synced/.kamehouse/integration-test-cred.enc file doesn't exist, creating one from the sample"
    cp -v docker/keys/integration-test-cred.enc ${HOME}/home-synced/.kamehouse/
  else
    log.info "home-synced/.kamehouse/integration-test-cred.enc file already exists. skipping"
  fi  

  if [ ! -f "${HOME}/home-synced/.kamehouse/keys/kamehouse.pkcs12" ]; then
    log.info "home-synced/.kamehouse/keys/kamehouse.pkcs12 file doesn't exist, creating one from the sample"
    cp -v kamehouse-commons-core/src/test/resources/commons/keys/sample.pkcs12 ${HOME}/home-synced/.kamehouse/keys/kamehouse.pkcs12
  else
    log.info "home-synced/.kamehouse/keys/kamehouse.pkcs12 file already exists. skipping"
  fi  

  if [ ! -f "${HOME}/home-synced/.kamehouse/keys/kamehouse.crt" ]; then
    log.info "home-synced/.kamehouse/keys/kamehouse.crt file doesn't exist, creating one from the sample"
    cp -v kamehouse-commons-core/src/test/resources/commons/keys/sample.crt ${HOME}/home-synced/.kamehouse/keys/kamehouse.crt
  else
    log.info "home-synced/.kamehouse/keys/kamehouse.crt file already exists. skipping"
  fi  
}

deployKameHouse() {
  ${HOME}/programs/kamehouse-shell/bin/kamehouse/deploy-kamehouse.sh -f
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
  while getopts ":hs" OPT; do
    case $OPT in
    ("h")
      printHelp
      exit 0
      ;;
    ("s")
      KAMEHOUSE_SHELL_ONLY=true
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
  echo -e "Usage: ${COL_PURPLE}install-kamehouse.sh${COL_NORMAL} [options]"
  echo -e ""
  echo -e "  Options:"  
  echo -e "     ${COL_BLUE}-h${COL_NORMAL} display help"
  echo -e "     ${COL_BLUE}-s${COL_NORMAL} install only kamehouse-shell scripts standalone"
}

main "$@"
