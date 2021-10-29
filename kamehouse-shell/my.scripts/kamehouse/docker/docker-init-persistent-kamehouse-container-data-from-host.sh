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

mainProcess() {
  log.info "Setting up persistent data in the volumes from the host file system"
  log.info "Run this script on the container's host ONCE to reset all the data in the volumes"

  log.info "Setup .ssh folder"
  scp -C -P ${DOCKER_PORT_SSH} ${HOME}/.ssh/* localhost:/home/nbrest/.ssh
  ssh -p ${DOCKER_PORT_SSH} nbrest@localhost -C 'chmod 0600 /home/nbrest/.ssh/id_rsa'

  log.info "Setup my.scripts folder"
  scp -C -P ${DOCKER_PORT_SSH} ${HOME}/my.scripts/.cred/.cred localhost:/home/nbrest/my.scripts/.cred/
  
  log.info "Setup .kamehouse folder"
  scp -C -P ${DOCKER_PORT_SSH} ${HOME}/home-synced/.kamehouse/.unlock.screen.pwd.enc localhost:/home/nbrest/.kamehouse
  scp -C -P ${DOCKER_PORT_SSH} ${HOME}/home-synced/.kamehouse/.vnc.server.pwd.enc localhost:/home/nbrest/.kamehouse

  log.info "Setup home-synced folder"
  scp -C -P ${DOCKER_PORT_SSH} ${HOME}/home-synced/.kamehouse/integration-test-cred.enc localhost:/home/nbrest/home-synced/.kamehouse
  scp -C -P ${DOCKER_PORT_SSH} ${HOME}/home-synced/.kamehouse/keys/* localhost:/home/nbrest/home-synced/.kamehouse/keys
  scp -C -r -P ${DOCKER_PORT_SSH} ${HOME}/home-synced/mysql localhost:/home/nbrest/home-synced/

  log.info "Re-init mysql kamehouse db from dump"
  ssh -p ${DOCKER_PORT_SSH} nbrest@localhost -C 'sudo /home/nbrest/my.scripts/common/mysql/add-mysql-user-nikolqs.sh'
  ssh -p ${DOCKER_PORT_SSH} nbrest@localhost -C '/home/nbrest/my.scripts/kamehouse/mysql-restore-kamehouse.sh'
}

main "$@"
