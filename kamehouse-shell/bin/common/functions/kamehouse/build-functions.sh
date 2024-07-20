buildKameHouseProject() {
  source ${HOME}/programs/kamehouse-shell/bin/kamehouse/set-java-home.sh true true
  log.info "Building ${COL_PURPLE}${PROJECT}${COL_DEFAULT_LOG} with profile ${COL_PURPLE}${MAVEN_PROFILE}${COL_DEFAULT_LOG}"
  
  exportGitCommitHash
  exportBuildVersion
  exportBuildDate
  buildMavenCommand
  executeMavenCommand
  
  if [[ "${MODULE}" == "kamehouse-mobile" ]]; then
    buildMobile
  fi
  cleanLogsInGitRepoFolder
}

buildFrontendCode() {
  npm install
  npm run build
  npm run scan
}

buildKameHouseStatic() {
  if [[ -z "${MODULE}" || "${MODULE}" == "kamehouse-ui" ]]; then
    buildKameHouseUiStatic
  fi
  if [[ -z "${MODULE}" || "${MODULE}" == "kamehouse-groot" ]]; then
    buildKameHouseGroot
  fi
  if [[ -z "${MODULE}" || "${MODULE}" == "kamehouse-mobile" ]]; then
    buildKameHouseMobileStatic
  fi
  if ${STATIC_ONLY}; then
    log.info "Finished building static code"
    exitSuccessfully    
  fi 
}

buildKameHouseUiStatic() {
  if [[ -z "${MODULE_SHORT}" 
    || "${MODULE_SHORT}" == "ui"
    || "${MODULE_SHORT}" == "groot"
    || "${MODULE_SHORT}" == "mobile" ]]; then
    cdToKameHouseModule "kamehouse-ui"
    log.info "Building ${COL_PURPLE}kamehouse-ui${COL_DEFAULT_LOG} static code"
    log.debug "Cleaning up dist directory"
    rm -rf ./dist/*

    buildFrontendCode

    log.debug "Updating sourcemap relative paths"
    find . -regex ".*.js.map" -type f -exec sed -i "s#../../src/main/typescript#../../../../src/main/typescript#g" {} \;

    log.info "Building kamehouse-ui bundle in dist folder"
    cp -r ./src/main/public/* ./dist
    echo "ui build date: $(date +%Y-%m-%d' '%H:%M:%S)" > ./dist/ui-build-date.txt 
    cdToRootDirFromModule "kamehouse-ui"
  fi
}

buildKameHouseGroot() {
  if [[ -z "${MODULE_SHORT}"
    || "${MODULE_SHORT}" == "groot"
    || "${MODULE_SHORT}" == "mobile" ]]; then
    cdToKameHouseModule "kamehouse-groot"
    log.info "Building ${COL_PURPLE}kamehouse-groot${COL_DEFAULT_LOG} static code"
    log.debug "Cleaning up dist directory"
    rm -rf ./dist/*

    buildFrontendCode

    log.debug "Updating sourcemap relative paths"
    find . -regex ".*.js.map" -type f -exec sed -i "s#../../../../../../../src/main/typescript#../../../../src/main/typescript#g" {} \;

    log.info "Building kamehouse-groot bundle in dist folder"
    cp -r ./src/main/public/* ./dist
    cp -r ./src/main/php/kame-house-groot/* ./dist/kame-house-groot
    echo "groot build date: $(date +%Y-%m-%d' '%H:%M:%S)" > ./dist/kame-house-groot/groot-build-date.txt 
    mv ./dist/kamehouse-groot/src/main/typescript/kame-house-groot/js ./dist/kame-house-groot/js
    mv ./dist/kamehouse-groot/src/main/typescript/kame-house-groot/kamehouse-groot/js ./dist/kame-house-groot/kamehouse-groot/js
    rm -rf ./dist/kamehouse-groot
    rm -rf ./dist/kamehouse-ui
    rm -rf ./dist/*.html
    cdToRootDirFromModule "kamehouse-groot"
  fi
}

buildKameHouseMobileStatic() {
  if [[ -z "${MODULE_SHORT}" || "${MODULE_SHORT}" == "mobile" ]]; then
    cdToKameHouseModule "kamehouse-mobile"
    log.info "Building ${COL_PURPLE}kamehouse-mobile${COL_DEFAULT_LOG} static code"
    log.debug "Cleaning up kamehouse-mobile www directory js files"
    rm -rf ./www/kame-house-mobile
    rm -rf ./www/kamehouse-mobile
    rm -rf ./www/kamehouse-ui

    buildFrontendCode

    log.debug "Updating sourcemap relative paths"
    find . -regex ".*.js.map" -type f -exec sed -i "s#../../../../../../../src/main/typescript#../../../src/main/typescript#g" {} \;
    
    log.info "Building kamehouse-mobile bundle in www folder"
    mkdir -p ./www/kame-house-mobile
    cp -r ./src/main/public/* ./www/kame-house-mobile
    echo "mobile build date: $(date +%Y-%m-%d' '%H:%M:%S)" > ./www/mobile-build-date.txt 
    mv ./www/kamehouse-mobile/src/main/typescript/kame-house-mobile/js ./www/kame-house-mobile/js
    mv ./www/kamehouse-mobile/src/main/typescript/kame-house-mobile/kamehouse-mobile/js ./www/kame-house-mobile/kamehouse-mobile/js
    mv ./www/kamehouse-mobile/src/main/typescript/kame-house-mobile/kamehouse-mobile/plugin/js ./www/kame-house-mobile/kamehouse-mobile/plugin/js  
    rm -rf ./www/kamehouse-mobile
    rm -rf ./www/kamehouse-ui

    exportGitCommitHash
    cdToKameHouseModule "kamehouse-mobile"
    setMobileBuildVersionAndKeys
    cdToRootDirFromModule "kamehouse-mobile"
  fi
}

buildMavenCommand() {
  MAVEN_COMMAND="mvn clean install -Dstyle.color=always -P ${MAVEN_PROFILE}"

  if ${FAST_BUILD}; then
    log.info "Executing fast build. Skipping checkstyle, findbugs and tests"
    MAVEN_COMMAND="${MAVEN_COMMAND} -Dmaven.test.skip=true -Dcheckstyle.skip=true -Dspotbugs.skip=true"
  fi

  if ${INTEGRATION_TESTS}; then
    if ${CONTINUE_INTEGRATION_TESTS_ON_ERRORS}; then
      MAVEN_COMMAND="mvn clean test-compile failsafe:integration-test -Dstyle.color=always -P ${MAVEN_PROFILE}"
    else
      MAVEN_COMMAND="mvn clean test-compile failsafe:integration-test failsafe:verify -Dstyle.color=always -P ${MAVEN_PROFILE}"
    fi
  fi

  if [ -n "${MODULE}" ]; then
    log.info "Building module ${COL_PURPLE}${MODULE}"
    if ${RESUME_BUILD}; then
      log.info "Resuming from last build"
      MAVEN_COMMAND="${MAVEN_COMMAND} -rf :${MODULE}"
    else
      MAVEN_COMMAND="${MAVEN_COMMAND} -pl :${MODULE} -am"
    fi
  else
    log.info "Building all modules"
  fi
  MAVEN_COMMAND="${MAVEN_COMMAND} -Dfilter.jdbc.password=${MARIADB_PASS_KAMEHOUSE}"
}

executeMavenCommand() {
  local MAVEN_COMMAND_MASKED="${MAVEN_COMMAND}"
  MAVEN_COMMAND_MASKED="`sed 's#filter.jdbc.password=.*#filter.jdbc.password=****#' <<<"${MAVEN_COMMAND_MASKED}"`"
  log.info "${MAVEN_COMMAND_MASKED}"
  ${MAVEN_COMMAND}
  checkCommandStatus "$?" "An error occurred building the project ${PROJECT_DIR}"
}

buildMobile() {
  log.info "${COL_PURPLE}Building kamehouse-mobile app"
  setKameHouseMobileApkPath
  buildKameHouseUiStatic
  buildKameHouseGroot
  buildKameHouseMobileStatic
  syncStaticFilesOnMobile
  cdToKameHouseModule "kamehouse-mobile"
  setLinuxBuildEnv
  source ${HOME}/programs/kamehouse-shell/bin/kamehouse/set-java-home-for-mobile.sh
  if ${CLEAN_CORDOVA_BEFORE_BUILD}; then
    cleanCordovaProject
  fi
  refreshCordovaPlugins
  if ${RESET_PACKAGE_JSON}; then
    # Reset unnecessary git changes after platform remove/add
    git checkout HEAD -- package.json
    git checkout HEAD -- package-lock.json
  fi
  setCordovaPlatforms
  setMobileBuildVersionAndKeys
  updateConfigWithGitHash
  buildCordovaProject
  source ${HOME}/programs/kamehouse-shell/bin/kamehouse/set-java-home.sh true true
  resetConfigFromGitHash
  cdToRootDirFromModule "kamehouse-mobile"
  deleteStaticFilesOnMobile
  uploadKameHouseMobileApkToGDrive
}

setLinuxBuildEnv() {
  if ${IS_LINUX_HOST}; then
    log.info "Setting android build env"
    export ANDROID_SDK_ROOT=${HOME}/Android/Sdk
    export PATH=${PATH}:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin
  fi
}

cleanCordovaProject() {
  log.debug "cordova clean ; cordova platform remove android ; cordova platform add android@${CORDOVA_ANDROID_PLATFORM_VERSION}"
  cordova clean
  cordova platform remove android
  cordova platform add android@${CORDOVA_ANDROID_PLATFORM_VERSION}
}

# Do this only when I really want to upgrade plugins, it might break my code with newer versions
refreshCordovaPlugins() {
  if ${REFRESH_CORDOVA_PLUGINS}; then
    log.info "Refreshing cordova plugins for this build"
    # remove all plugins I ever added here, even the ones are no longer in the project
    cordova plugin remove cordova-plugin-inappbrowser # removed from project
    cordova plugin remove cordova-plugin-advanced-http
    cordova plugin remove cordova-plugin-file

    cordova plugin add cordova-plugin-advanced-http
    cordova plugin add cordova-plugin-file
  else
    log.debug "Not refreshing cordova plugins for this build"
  fi 
}

setCordovaPlatforms() {
  log.info "Setting cordova platforms"
  cordova platform add android@${CORDOVA_ANDROID_PLATFORM_VERSION}
}


# runs from root directory of kamehouse project
syncStaticFilesOnMobile() {
  ${HOME}/programs/kamehouse-shell/bin/kamehouse/kamehouse-mobile-resync-static-files.sh -c
}

setMobileBuildVersionAndKeys() {
  log.debug "Setting build version and encryption key"
  cp -f pom.xml www/kame-house-mobile/
  echo "${GIT_COMMIT_HASH}" > www/kame-house-mobile/git-commit-hash.txt
  date +%Y-%m-%d' '%H:%M:%S > www/kame-house-mobile/build-date.txt
  echo "${KAMEHOUSE_MOBILE_ENCRYPTION_KEY}" > www/kame-house-mobile/encryption.key
}

buildCordovaProject() {
  log.info "Executing: cordova build android"
  cordova build android
  checkCommandStatus "$?" "An error occurred building kamehouse-mobile"

  log.info "Built apk file status"
  ls -lh ${KAMEHOUSE_ANDROID_APK_PATH}
}

deleteStaticFilesOnMobile() {
  ${HOME}/programs/kamehouse-shell/bin/kamehouse/kamehouse-mobile-resync-static-files.sh -c -d
}

updateConfigWithGitHash() {
  log.debug "Setting git commit hash on config.xml"
  cp -f config.xml config-pre-build.xml
  local RELEASE_VERSION=`grep -e "<version>.*1-KAMEHOUSE-SNAPSHOT</version>" pom.xml | awk '{print $1}'`
  RELEASE_VERSION=`echo ${RELEASE_VERSION:9:4}`
  local APP_VERSION="<widget id=\"com.nicobrest.kamehouse\" version=\"${RELEASE_VERSION}.1"
  local APP_VERSION_WITH_HASH="<widget id=\"com.nicobrest.kamehouse\" version=\"${RELEASE_VERSION}.1-${GIT_COMMIT_HASH}"

  log.debug "Setting mobile app version to: ${APP_VERSION_WITH_HASH}"
  sed -i "s+${APP_VERSION}+${APP_VERSION_WITH_HASH}+g" config.xml
}

resetConfigFromGitHash() {
  log.debug "Resetting config.xml git commit hash after build"
  mv -f config-pre-build.xml config.xml
}

uploadKameHouseMobileApkToGDrive() {
  if [ -d "${KAMEHOUSE_MOBILE_GDRIVE_PATH_WIN}" ]; then
    log.info "${COL_PURPLE}Uploading${COL_DEFAULT_LOG} kamehouse-mobile apk ${COL_PURPLE}to google drive${COL_DEFAULT_LOG} folder ${KAMEHOUSE_MOBILE_GDRIVE_PATH_WIN}"
    cp ${KAMEHOUSE_ANDROID_APK_PATH} "${KAMEHOUSE_MOBILE_GDRIVE_PATH_WIN}/kamehouse.apk"
  fi

  if [ -d "${HOME}/GoogleDrive" ]; then
    log.info "Mounting google drive"
    google-drive-ocamlfuse ${HOME}/GoogleDrive
    sleep 8
  fi

  if [ -d "${KAMEHOUSE_MOBILE_GDRIVE_PATH_LIN}" ]; then
    log.info "${COL_PURPLE}Uploading${COL_DEFAULT_LOG} kamehouse-mobile apk ${COL_PURPLE}to google drive${COL_DEFAULT_LOG} folder ${KAMEHOUSE_MOBILE_GDRIVE_PATH_LIN}"
    cp ${KAMEHOUSE_ANDROID_APK_PATH} "${KAMEHOUSE_MOBILE_GDRIVE_PATH_LIN}/kamehouse.apk"
  fi
}

exportGitCommitHash() {
  cdToRootDirFromModule "kamehouse-mobile"
  log.info "Exporting git commit hash to commons-core"
  GIT_COMMIT_HASH=`git rev-parse --short HEAD`
  echo "${GIT_COMMIT_HASH}" > kamehouse-commons-core/src/main/resources/git-commit-hash.txt
}

exportBuildVersion() {
  cdToRootDirFromModule "kamehouse-mobile"
  log.info "Exporting build version to commons-core"
  local KAMEHOUSE_RELEASE_VERSION=`grep -e "<version>.*1-KAMEHOUSE-SNAPSHOT</version>" pom.xml | awk '{print $1}'`
  KAMEHOUSE_RELEASE_VERSION=`echo ${KAMEHOUSE_RELEASE_VERSION:9:6}`
  echo "${KAMEHOUSE_RELEASE_VERSION}" > kamehouse-commons-core/src/main/resources/build-version.txt
}

exportBuildDate() {
  cdToRootDirFromModule "kamehouse-mobile"
  log.info "Exporting build date to commons-core"
  date +%Y-%m-%d' '%H:%M:%S > kamehouse-commons-core/src/main/resources/build-date.txt
}
