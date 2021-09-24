#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
	echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
	exit 1
fi

# Global variables
REPOSITORY_NAME="my.scripts"

mainProcess() {
  ###########
  # SSH all #
  ###########

  ### Create the remote named all with fetch from the bitbucket repo
  git remote remove all
  git remote add all git@bitbucket.org:nbrest/${REPOSITORY_NAME}.git

  ### Add the bitbucket repo to the remote all push
  git remote set-url --add --push all git@bitbucket.org:nbrest/${REPOSITORY_NAME}.git

  ### Add the github repo to the remote all push
  #git remote set-url --add --push all git@github.com:nbrest/${REPOSITORY_NAME}.git

  #######
  # SSH #
  #######

  ### Create a remote named bitbucket to push using ssh to github
  git remote remove bitbucket-ssh
  git remote add bitbucket-ssh git@bitbucket.org:nbrest/${REPOSITORY_NAME}.git

  ### Create a remote named githubssh to push using ssh to github
  git remote remove github-ssh
  git remote add github-ssh git@github.com:nbrest/${REPOSITORY_NAME}.git

  #########
  # HTTPS #
  #########

  ### Create a remote named bitbucket to be able to push only to bitbucket
  git remote remove bitbucket-https
  git remote add bitbucket-https https://nbrest@bitbucket.org/nbrest/${REPOSITORY_NAME}.git

  ### Create a remote named github to be able to push only to github
  git remote remove github-https
  git remote add github-https https://nbrest@github.com/nbrest/${REPOSITORY_NAME}.git

  ### Remove legacy remotes:
  git remote remove bitbucket
  git remote remove bitbucketssh

  git remote remove github
  git remote remove githubssh

  ### list all the remotes
  git remote -v 
}

main "$@"
