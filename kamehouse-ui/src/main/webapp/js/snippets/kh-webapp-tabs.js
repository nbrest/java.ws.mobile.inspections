/**
 * Kamehouse webapp tabs functions.
 */
var kameHouseWebappTabsManager;

function main() {
  kameHouseWebappTabsManager = new KameHouseWebappTabsManager();
  kameHouseWebappTabsManager.importTabs();
}

/**
 * Prototype to manage the kamehouse webapp tabs.
 */
function KameHouseWebappTabsManager() {
  let self = this;
  this.cookiePrefix = '';

  /**
   * Set the cookie prefix for the tab manager.
   * For example use 'kh-admin-ehcache'.
   */
  this.setCookiePrefix = (cookiePrefix) => {
    self.cookiePrefix = cookiePrefix;
  }

  /**
   * Load the current state from the cookies.
   */
   this.loadStateFromCookies = () => {
    let currentTab = cookiesUtils.getCookie(self.cookiePrefix + '-current-tab');
    if (!currentTab || currentTab == '') {
      currentTab = 'tab-admin';
    }
    self.openTab(currentTab);
  }

  /**
   * Open the tab specified by its id.
   */
  this.openTab = (selectedTabDivId) => {
    // Set current-tab cookie
    cookiesUtils.setCookie(self.cookiePrefix + '-current-tab', selectedTabDivId);

    // Update tab links
    let kamehouseTabLinks = document.getElementsByClassName("kh-webapp-tab-link");
    for (let i = 0; i < kamehouseTabLinks.length; i++) {
      domUtils.classListRemove(kamehouseTabLinks[i], "active");
    }
    let selectedTabLink = document.getElementById(selectedTabDivId + '-link');
    domUtils.classListAdd(selectedTabLink, "active");

    // Update tab content visibility
    let kamehouseTabContent = document.getElementsByClassName("kh-webapp-tab-content");
    for (let i = 0; i < kamehouseTabContent.length; i++) {
      domUtils.setStyle(kamehouseTabContent[i], "display", "none");
    }
    let selectedTabDiv = document.getElementById(selectedTabDivId);
    domUtils.setStyle(selectedTabDiv, "display", "block");
  }

  /**
   * Import tabs.
   */
  this.importTabs = () => {
    domUtils.append($('head'), '<link rel="stylesheet" type="text/css" href="/kame-house/css/snippets/kh-webapp-tabs.css">');
    $("#kh-webapp-tabs-wrapper").load("/kame-house/html-snippets/kh-webapp-tabs.html", () => {
      moduleUtils.setModuleLoaded("kameHouseWebappTabsManager");
    });
  }

}

/**
 * Call main.
 */
$(document).ready(main);