#!/bin/bash

# Import common functions
source ${HOME}/my.scripts/common/common-functions.sh
if [ "$?" != "0" ]; then
	echo -e "\033[1;36m$(date +%Y-%m-%d' '%H:%M:%S)\033[0;39m - [\033[1;31mERROR\033[0;39m] - \033[1;31mAn error occurred importing common-functions.sh\033[0;39m"
	exit 1
fi

LOG_PROCESS_TO_FILE=true

mainProcess() {
  export HOME=`${HOME}/my.scripts/kamehouse/get-userhome.sh`
  TOMCAT_DIR=`${HOME}/my.scripts/kamehouse/get-tomcat-dir.sh`
  cd ${TOMCAT_DIR}
  if ${IS_LINUX_HOST}; then
    USERNAME=`${HOME}/my.scripts/kamehouse/get-username.sh`  
    log.info "Starting tomcat ${TOMCAT_DIR} as user ${USERNAME}"
    USER_UID=`sudo cat /etc/passwd | grep ${USERNAME} | cut -d ':' -f3`
    sudo su - ${USERNAME} -c "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/${USER_UID}/bus DISPLAY=:0.0 ${TOMCAT_DIR}/bin/startup.sh"
  else
    log.info "Starting tomcat ${TOMCAT_DIR}"
    cd ${TOMCAT_DIR}
    powershell.exe -c "Start-Process ./bin/startup.bat" &
  fi
}

main "$@"
