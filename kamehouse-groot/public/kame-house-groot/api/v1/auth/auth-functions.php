<?php
/**
 * Endpoint: /kame-house-groot/api/v1/auth/auth-functions.php
 * 
 * [INTERNAL] - To be imported from other php files. Not to be directly called from frontend code.
 * 
 * Common functions used in the /auth APIs
 * 
 * @author nbrest
 */

/**
 * Unlock the session to enable multiple requests to be executed in parallel in the same session.
 */
function unlockSession() {
  session_write_close();
}

/**
 * Check if the user is logged in.
 */
function isLoggedIn() {
  if (isset($_SESSION['logged-in'])) {
    return true; 
  } else {
    return false;
  }
}

/**
 * Checks if the authorization header is set in the request.
 */
function isAuthorizationHeaderSet() {
  if (isset($_SERVER["PHP_AUTH_USER"]) && isset($_SERVER["PHP_AUTH_PW"])) {
    return true;
  } else {
    return false;
  }
}

/**
 * Get the username from the auth header.
 */
function getUsernameFromAuthorizationHeader() {
  return $_SERVER["PHP_AUTH_USER"];
}

/**
 * Get the password from the auth header.
 */
function getPasswordFromAuthorizationHeader() {
  return $_SERVER["PHP_AUTH_PW"];
}

/**
 * Checks if the specified login credentials are valid executing a shell script to validate the user
 * with the .htpasswd file.
 */
function isAuthorizedUser($username, $password) {
  if(!isValidInputForShell($username)) {
    return false;
  }

  if(!isValidInputForShell($password)) {
    return false;
  }

  $isAuthorizedUser = false;
  $scriptArgs = $username . " " . $password;

  if (isLinuxHost()) {
    /**
     * This requires to give permission to www-data to execute. Check API exec-script.php for more details.
     */
    $shellUsername = trim(shell_exec("/var/www/programs/kamehouse-shell/bin/kamehouse/get-username.sh"));
    $shellCommandOutput = shell_exec("sudo -u " . $shellUsername . " /var/www/programs/kamehouse-shell/bin/common/sudoers/www-data/exec-script.sh -s 'kamehouse/kamehouse-groot-login.sh' -a '" . $scriptArgs . "'");
  } else {
    $shellCommandOutput = shell_exec("%USERPROFILE%/programs/kamehouse-shell/bin/win/bat/git-bash.bat -c \"~/programs/kamehouse-shell/bin/common/sudoers/www-data/exec-script.sh -s 'kamehouse/kamehouse-groot-login.sh' -a '" . $scriptArgs . "'\"");
  }
  $shellCommandOutput = explode("\n", $shellCommandOutput);

  foreach ($shellCommandOutput as $shellCommandOutputLine) {
    if (startsWith($shellCommandOutputLine, 'loginStatus=SUCCESS')) {
      $isAuthorizedUser = true;
    }
  }
  
  return $isAuthorizedUser;
}
?> 
