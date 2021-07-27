#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
	echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
	exit 1
fi

LOG_PROCESS_TO_FILE=true

mainProcess() {
  ${HOME}/my.scripts/win/git/git-pull-hacking.sh
  ${HOME}/my.scripts/win/git/git-pull-java-web-kamehouse.sh
  ${HOME}/my.scripts/win/git/git-pull-kh-webserver.sh
  ${HOME}/my.scripts/win/git/git-pull-learn-java.sh
  ${HOME}/my.scripts/win/git/git-pull-my-scripts.sh
  ${HOME}/my.scripts/win/git/git-pull-programming.sh
  ${HOME}/my.scripts/win/git/git-pull-prod-java-web-kamehouse.sh
  ${HOME}/my.scripts/win/git/git-pull-texts.sh
}

main "$@"