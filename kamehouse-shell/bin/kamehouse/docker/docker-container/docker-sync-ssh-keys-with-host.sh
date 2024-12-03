#!/bin/bash

# Import common functions
source ${HOME}/programs/kamehouse-shell/bin/common/functions/common-functions.sh
if [ "$?" != "0" ]; then
  echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
  exit 99
fi

mainProcess() {
  source ${HOME}/.kamehouse/.kamehouse-docker-container-env
  ssh-keyscan ${DOCKER_HOST_IP} >> ~/.ssh/known_hosts
  ssh ${DOCKER_HOST_USERNAME}@${DOCKER_HOST_IP} -C "echo 'ssh from docker container to host successful'"
}

main "$@"
