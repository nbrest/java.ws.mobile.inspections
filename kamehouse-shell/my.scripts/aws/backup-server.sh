#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
  echo "$(date +%Y-%m-%d' '%H:%M:%S) - [ERROR] - An error occurred importing common-functions.sh"
  exit 1
fi

source ${HOME}/my.scripts/common/backup/backup-server-functions.sh
if [ "$?" != "0" ]; then
	echo "$(date +%Y-%m-%d' '%H:%M:%S) - [ERROR] - An error occurred importing backup-server-functions.sh"
	exit 1
fi

# Global variables
HOSTNAME="aws"
USER="ubuntu"

backupTomcat() {
  log.info "Backing up tomcat8 config"
  mkdir -p ${PROJECT_DIR}/${HOSTNAME}/etc/tomcat8
  checkCommandStatus "$?" "An error occurred creating directories"
  sudo cp -vrf /etc/tomcat8/* ${PROJECT_DIR}/${HOSTNAME}/etc/tomcat8/
  checkCommandStatus "$?" "An error occurred during file copy"

  log.info "Backing up tomcat8 home dir"
  mkdir -p ${PROJECT_DIR}/${HOSTNAME}/var/lib/tomcat8
  checkCommandStatus "$?" "An error occurred creating directories"
  sudo cp -vrf /var/lib/tomcat8/.config ${PROJECT_DIR}/${HOSTNAME}/var/lib/tomcat8/
  checkCommandStatus "$?" "An error occurred during file copy"
  sudo cp -vrf /var/lib/tomcat8/git ${PROJECT_DIR}/${HOSTNAME}/var/lib/tomcat8/
  checkCommandStatus "$?" "An error occurred during file copy"
}

customBackupTask() {
  log.info "Backing up letsencrypt config"
  mkdir -p ${PROJECT_DIR}/${HOSTNAME}/etc/letsencrypt
  checkCommandStatus "$?" "An error occurred creating directories"
  sudo cp -vrf /etc/letsencrypt/* ${PROJECT_DIR}/${HOSTNAME}/etc/letsencrypt/
  checkCommandStatus "$?" "An error occurred during file copy"
  
  log.info "Backing up home programs and videos folders"
  cp -vrf ${HOME}/programs ${PROJECT_DIR}/${HOSTNAME}${HOME}/
  checkCommandStatus "$?" "An error occurred during file copy"
  cp -vrf ${HOME}/videos ${PROJECT_DIR}/${HOSTNAME}${HOME}/
  checkCommandStatus "$?" "An error occurred during file copy"  
}

main "$@"
