<?php
/**
 * Check if the user is logged in. 
 * There's no roles in GRoot. Only admin users. So if the user is logged in, it has access to any page.
 * 
 * Import this in every page that requires groot authorization by calling:
 * `<?php require_once("../../api/v1/auth/authorize-page.php") ?>`
 * At the beginning of that page. The rest of the page should be static html code
 * 
 * @author nbrest
 */
mainAuthorizePage();
?> 

<?php

  /**
   * Check if there's an active session, otherwise redirect to login page.
   */
  function mainAuthorizePage() {
    initAuthorizePage();

    if (isLoggedIn()) {
      unlockSession();
      return;
    }
    unlockSession();
    
    if (isset($_SERVER['REQUEST_URI'])) {
      header('Location: /kame-house-groot/login.html?referrer=' . $_SERVER['REQUEST_URI']);
      exit;
    }

    header('Location: /kame-house-groot/login.html');
  	exit;
  }

  /**
   * 
   */
  function initAuthorizePage() {
    session_start();
    require_once("auth-functions.php");
  }
?>