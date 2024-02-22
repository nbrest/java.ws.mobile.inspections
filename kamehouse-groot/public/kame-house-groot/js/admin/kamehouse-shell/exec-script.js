/**
 * Loader for kamehouse shell scripts.
 * 
 * @author nbrest
 */
class ExecScriptLoader {

  /**
   * Load the exec script loader extension.
   */
  load() {
    this.setBanners();
    this.#setScriptNameAndArgsFromUrlParams();
    kameHouse.util.module.waitForModules(["kameHouseGrootSession"], () => {
      this.#handleSessionStatus();
    });
  }

  /**
   * Set random banners.
   */
  setBanners() {
    kameHouse.util.banner.setRandomAllBanner();
  }

  /**
   * Return the js shell executor.
   */
  getShell() {
    return kameHouse.extension.kameHouseShell;
  } 
  
  /**
   * Execute script from url parameters.
   */
  executeFromUrlParams() {
    this.#setScriptInProgressView();
    const urlParams = new URLSearchParams(window.location.search);
    const scriptName = urlParams.get('script');
    const args = urlParams.get('args');
    const executeOnDockerHost = urlParams.get('executeOnDockerHost');
    const timeout = urlParams.get('timeout');
    this.#execute(scriptName, args, executeOnDockerHost, timeout);
  }

  /** Allow the user to download the full bash script output */
  downloadBashScriptOutput() {
    const clientDate = new Date();
    const clientMonth = clientDate.getMonth() + 1;
    const timestamp = clientDate.getDate() + "-" + clientMonth + "-" + clientDate.getFullYear() + "_" + clientDate.getHours() + "-" + clientDate.getMinutes() + "-" + clientDate.getSeconds();
    const downloadLink = this.#getDownloadLink(timestamp);
    kameHouse.util.dom.appendChild(document.body, downloadLink);
    downloadLink.click();
    kameHouse.util.dom.removeChild(document.body, downloadLink);
  }  

  /**
   * Execute script success callback.
   */
  #successCallback() {
    this.#scriptExecCallback();
  }

  /**
   * Execute script error callback.
   */
  #errorCallback() {
    this.#scriptExecCallback();
  }

  /**
   * Set script in progress view.
   */
  #setScriptInProgressView() {
    this.#updateScriptExecutionStartDate();
    kameHouse.util.dom.addClass(document.getElementById("kamehouse-shell-output-header"), "hidden-kh");
    kameHouse.util.dom.addClass(document.getElementById("btn-execute-script"), "hidden-kh");
    kameHouse.util.dom.addClass(document.getElementById("btn-download-kamehouse-shell-output"), "hidden-kh");
    this.#setBannerScriptStatus("in progress...");
  }

  /**
   * Execute script.
   */  
  #execute(scriptName, args, executeOnDockerHost, timeout) {
    kameHouse.util.module.waitForModules(["kameHouseShell"], () => {
      this.getShell().execute(scriptName, args, executeOnDockerHost, timeout, 
        (scriptOutput) => {this.#successCallback(scriptOutput)}, 
        (scriptOutput) => {this.#errorCallback(scriptOutput)});
    });  
  }

  /**
   * Execute script global callback.
   */
  #scriptExecCallback() {
    this.#updateScriptExecutionEndDate();
    kameHouse.util.dom.removeClass(document.getElementById('kamehouse-shell-output-header'), "hidden-kh");
    kameHouse.util.dom.removeClass(document.getElementById('btn-execute-script'), "hidden-kh");
    kameHouse.util.dom.removeClass(document.getElementById('btn-download-kamehouse-shell-output'), "hidden-kh");  
    this.#setBannerScriptStatus("finished!");
  }

  /**
   * Set banner script status.
   */
  #setBannerScriptStatus(status) {
    kameHouse.util.dom.setHtml(document.getElementById("banner-script-status"), status);
  }

  /** Update script execution end date */
  #updateScriptExecutionEndDate() {
    const clientTimeAndDate = this.#getClientTimeAndDate();
    kameHouse.util.dom.setHtml(document.getElementById("st-script-exec-end-date"), clientTimeAndDate);
  }

  /** Update script execution start date */
  #updateScriptExecutionStartDate() {
    const clientTimeAndDate = this.#getClientTimeAndDate();
    kameHouse.util.dom.setHtml(document.getElementById("st-script-exec-start-date"), clientTimeAndDate);
    kameHouse.util.dom.setHtml(document.getElementById("st-script-exec-end-date"), "");
  }

  /** Get the current time and date on the client */
  #getClientTimeAndDate() {
    const clientDate = new Date();
    const clientMonth = clientDate.getMonth() + 1;
    return clientDate.getDate() + "/" + clientMonth + "/" + clientDate.getFullYear() + " - " + clientDate.getHours() + ":" + clientDate.getMinutes() + ":" + clientDate.getSeconds();
  }

  /** Handle Session Status */
  #handleSessionStatus() {
    this.#updateServerName(kameHouse.extension.groot.session);
  }

  /** Update server name */
  #updateServerName(sessionStatus) {
    if (!kameHouse.core.isEmpty(sessionStatus.server)) {
      kameHouse.util.dom.setHtml(document.getElementById("st-server-name"), sessionStatus.server);
      kameHouse.util.dom.setHtml(document.getElementById("banner-server-name"), sessionStatus.server);
    }
  }

  /** Set script name and args */
  #setScriptNameAndArgsFromUrlParams() {
    const urlParams = new URLSearchParams(window.location.search);
    const scriptName = urlParams.get('script');
    const args = urlParams.get('args');
    const executeOnDockerHost = urlParams.get('executeOnDockerHost');
    kameHouse.util.dom.setHtml(document.getElementById("st-script-name"), scriptName);
    kameHouse.util.dom.setHtml(document.getElementById("st-script-args"), args);
    kameHouse.util.dom.setHtml(document.getElementById("st-script-exec-docker-host"), executeOnDockerHost);
  }

  /**
   * Get download link.
   */
  #getDownloadLink(timestamp) {
    return kameHouse.util.dom.getA({
      href: 'data:text/plain;charset=utf-8,' + encodeURIComponent(this.getShell().getBashScriptOutput()),
      download:  "kamehouse-shell-output-" + timestamp + ".log",
      class: "hidden-kh"
    }, null);
  }
}

kameHouse.ready(() => {
  kameHouse.addExtension("execScriptLoader", new ExecScriptLoader());
});