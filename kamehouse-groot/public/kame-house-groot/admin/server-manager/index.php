<?php require_once("../../api/v1/auth/authorize-page.php") ?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width">
<meta name="author" content="nbrest">
<meta name="description" content="kame-house application">
<meta name="keywords" content="kame-house nicobrest nbrest">
<meta name="mobile-web-app-capable" content="yes">

<title>GRoot - Server Manager</title>

<link rel="shortcut icon" href="/kame-house-groot/favicon.ico" type="image/x-icon" />
<script src="/kame-house/lib/js/jquery-2.0.3.min.js"></script>
<script src="/kame-house/js/global.js"></script>
<script src="/kame-house-groot/js/global.js"></script>
<link rel="stylesheet" href="/kame-house/lib/css/bootstrap.min.css" />
<link rel="stylesheet" href="/kame-house/css/global.css" />
<link rel="stylesheet" href="/kame-house-groot/css/global.css" />
<link rel="stylesheet" href="/kame-house-groot/css/admin/server-manager.css" />
</head>
<body>
  <div id="groot-menu-wrapper"></div>
  <div class="banner-wrapper">
  <div id="banner" class="fade-in-out-15s banner-goku-ssj4-earth">
    <div class="default-layout banner-text">
      <h1>Server Manager</h1>
      <div id="banner-server-name"></div>
    </div>
  </div>  
  </div>
  <div class="tabs-groot bg-lighter-1-kh">
    <div class="default-layout">
      <button id="tab-git-link" class="tab-groot-link"
        onclick="openTab('tab-git', 'kh-groot-server-manager')">Git</button>

      <button id="tab-deployment-link" class="tab-groot-link"
        onclick="openTab('tab-deployment', 'kh-groot-server-manager')">Deployment</button>

      <button id="tab-media-link" class="tab-groot-link"
        onclick="openTab('tab-media', 'kh-groot-server-manager')">Media</button>

      <button id="tab-power-link" class="tab-groot-link"
        onclick="openTab('tab-power', 'kh-groot-server-manager')">Power</button>

      <button id="tab-tail-log-link" class="tab-groot-link"
        onclick="openTab('tab-tail-log', 'kh-groot-server-manager')">Tail Log</button>
    </div>
  </div>

    <div id="tab-git" class="default-layout tab-groot-content p-7-d-kh w-70-pc-kh w-100-pc-m-kh">

      <br>
      <h4 class="h4-kh txt-l-d-kh txt-c-m-kh">Git</h4>
      <br>
      <div class="default-layout w-80-pc-kh w-100-pc-m-kh">
        <span class="bold-kh">Pull latest changes in all my git repos: </span>
        <img class="img-btn-kh m-10-d-r-kh" onclick="gitManager.pullAll()" 
          src="/kame-house/img/other/git-pull-request-blue.png" alt="Git Pull All" title="Git Pull All"/>
        <img class="img-btn-kh m-10-d-r-kh" onclick="gitManager.pullAllAllServers()" 
          src="/kame-house/img/other/cloud-up-down-blue.png" alt="Git Pull All - All Servers" title="Git Pull All - All Servers"/>
        <br><br>
      </div>
      <p class="p-15-m-kh">You can also trigger a git pull in all servers using the cloud button</p>

    </div> <!-- tab-git -->

    <div id="tab-deployment" class="default-layout tab-groot-content p-7-d-kh">

      <br>
      <h4 class="h4-kh txt-l-d-kh txt-c-m-kh">Deployment</h4>
      <p class="default-layout tomcat-description">Manage all the kamehouse modules installed in the current server. Login to kame-house to get the current build version and date of the tomcat modules. You can also deploy to all servers using the cloud buttons. Deploying all servers also deploys the non-tomcat modules. As well as check the status of the current tomcat process and start and stop the process when required.</p>
      <span class="bold-kh">Deploy all modules: </span>
      <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployAllModules()" 
        src="/kame-house/img/other/rocket-green.png" alt="Deploy All Modules" title="Deploy All Modules"/>
      <img class="img-btn-kh" onclick="deploymentManager.deployAllModulesAllServers()" 
        src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy All Modules - All Servers" title="Deploy All Modules - All Servers"/>

      <img class="img-btn-kh m-5-d-kh m-5-d-kh fl-r-d-kh" onclick="deploymentManager.refreshServerView()"
        src="/kame-house/img/other/sync-btn-info.png" alt="Refresh" title="Refresh"/>

      <table id="mst-admin" 
        class="table table-responsive table-bordered table-kh table-responsive-kh table-bordered-kh">
        <tr class="table-kh-header">
          <td>module</td>
          <td class="tomcat-modules-table-path">path</td>
          <td>status</td>
          <td>build version</td>
          <td class="tomcat-modules-table-build-date">build date</td>
          <td class="tomcat-modules-table-controls">controls</td>
          <td class="tomcat-modules-table-deployment">deployment</td>
        </tr>
        <tr>
          <td><div id="mst-admin-header-val">admin</div></td>
          <td>/kame-house-admin</td>
          <td id="mst-admin-status-val"><img class="img-tomcat-manager-status" src="/kame-house/img/other/ball-blue.png" alt="status" title="status"/></td>
          <td id="mst-admin-build-version-val">N/A</td>
          <td id="mst-admin-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-7-d-r-kh" onclick="deploymentManager.startModule('admin')" 
              src="/kame-house/img/mplayer/play-green.png" alt="Start" title="Start"/>
            <img class="img-btn-kh" onclick="deploymentManager.stopModule('admin')" 
              src="/kame-house/img/mplayer/stop.png" alt="Stop" title="Stop"/>
          </td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.undeployModule('admin')" 
              src="/kame-house/img/other/cancel.png" alt="Undeploy" title="Undeploy"/>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('admin')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('admin')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>
        <tr>
          <td><div id="mst-media-header-val">media</div></td>
          <td>/kame-house-media</td>
          <td id="mst-media-status-val"><img class="img-tomcat-manager-status" src="/kame-house/img/other/ball-blue.png" alt="status" title="status"/></td>
          <td id="mst-media-build-version-val">N/A</td>
          <td id="mst-media-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-7-d-r-kh" onclick="deploymentManager.startModule('media')" 
              src="/kame-house/img/mplayer/play-green.png" alt="Start" title="Start"/>
            <img class="img-btn-kh" onclick="deploymentManager.stopModule('media')" 
              src="/kame-house/img/mplayer/stop.png" alt="Stop" title="Stop"/>
          </td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.undeployModule('media')" 
              src="/kame-house/img/other/cancel.png" alt="Undeploy" title="Undeploy"/>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('media')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('media')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>
        <tr>
          <td><div id="mst-tennisworld-header-val">tennisworld</div></td>
          <td>/kame-house-tennisworld</td>
          <td id="mst-tennisworld-status-val"><img class="img-tomcat-manager-status" src="/kame-house/img/other/ball-blue.png" alt="status" title="status"/></td>
          <td id="mst-tennisworld-build-version-val">N/A</td>
          <td id="mst-tennisworld-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-7-d-r-kh" onclick="deploymentManager.startModule('tennisworld')" 
              src="/kame-house/img/mplayer/play-green.png" alt="Start" title="Start"/>
            <img class="img-btn-kh" onclick="deploymentManager.stopModule('tennisworld')" 
              src="/kame-house/img/mplayer/stop.png" alt="Stop" title="Stop"/>
          </td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.undeployModule('tennisworld')" 
              src="/kame-house/img/other/cancel.png" alt="Undeploy" title="Undeploy"/>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('tennisworld')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('tennisworld')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>
        <tr>
          <td><div id="mst-testmodule-header-val">testmodule</div></td>
          <td>/kame-house-testmodule</td>
          <td id="mst-testmodule-status-val"><img class="img-tomcat-manager-status" src="/kame-house/img/other/ball-blue.png" alt="status" title="status"/></td>
          <td id="mst-testmodule-build-version-val">N/A</td>
          <td id="mst-testmodule-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-7-d-r-kh" onclick="deploymentManager.startModule('testmodule')" 
              src="/kame-house/img/mplayer/play-green.png" alt="Start" title="Start"/>
            <img class="img-btn-kh" onclick="deploymentManager.stopModule('testmodule')" 
              src="/kame-house/img/mplayer/stop.png" alt="Stop" title="Stop"/>
          </td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.undeployModule('testmodule')" 
              src="/kame-house/img/other/cancel.png" alt="Undeploy" title="Undeploy"/>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('testmodule')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('testmodule')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>
        <tr>
          <td><div id="mst-ui-header-val">ui</div></td>
          <td>/kame-house</td>
          <td id="mst-ui-status-val"><img class="img-tomcat-manager-status" src="/kame-house/img/other/ball-blue.png" alt="status" title="status"/></td>
          <td id="mst-ui-build-version-val">N/A</td>
          <td id="mst-ui-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-7-d-r-kh" onclick="deploymentManager.startModule('ui')" 
              src="/kame-house/img/mplayer/play-green.png" alt="Start" title="Start"/>
            <img class="img-btn-kh" onclick="deploymentManager.stopModule('ui')" 
              src="/kame-house/img/mplayer/stop.png" alt="Stop" title="Stop"/>
          </td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.undeployModule('ui')" 
              src="/kame-house/img/other/cancel.png" alt="Undeploy" title="Undeploy"/>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('ui')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('ui')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>
        <tr>
          <td><div id="mst-vlcrc-header-val">vlcrc</div></td>
          <td>/kame-house-vlcrc</td>
          <td id="mst-vlcrc-status-val"><img class="img-tomcat-manager-status" src="/kame-house/img/other/ball-blue.png" alt="status" title="status"/></td>
          <td id="mst-vlcrc-build-version-val">N/A</td>
          <td id="mst-vlcrc-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-7-d-r-kh" onclick="deploymentManager.startModule('vlcrc')" 
              src="/kame-house/img/mplayer/play-green.png" alt="Start" title="Start"/>
            <img class="img-btn-kh" onclick="deploymentManager.stopModule('vlcrc')" 
              src="/kame-house/img/mplayer/stop.png" alt="Stop" title="Stop"/>
          </td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.undeployModule('vlcrc')" 
              src="/kame-house/img/other/cancel.png" alt="Undeploy" title="Undeploy"/>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('vlcrc')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('vlcrc')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>
      </table>
      <br>
      <table class="table table-responsive table-bordered table-kh table-responsive-kh table-bordered-kh">
        <tr class="table-kh-header">
          <td>module</td>
          <td class="non-tomcat-modules-table-build-version">build version</td>
          <td class="non-tomcat-modules-table-build-date">build date</td>
          <td class="non-tomcat-modules-table-deployment">deployment</td>
        </tr>
        <tr>
          <td><div id="mst-cmd-header-val">cmd</div></td>
          <td id="mst-cmd-build-version-val">N/A</td>
          <td id="mst-cmd-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('cmd')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('cmd')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>
        <tr>
          <td><div id="mst-groot-header-val">groot</div></td>
          <td id="mst-groot-build-version-val">N/A</td>
          <td id="mst-groot-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('groot')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('groot')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>
        <tr>
          <td><div id="mst-shell-header-val">shell</div></td>
          <td id="mst-shell-build-version-val">N/A</td>
          <td id="mst-shell-build-date-val">N/A</td>
          <td>
            <img class="img-btn-kh m-10-d-r-kh" onclick="deploymentManager.deployModule('shell')" 
              src="/kame-house/img/other/rocket-green.png" alt="Deploy" title="Deploy"/>
            <img class="img-btn-kh" onclick="deploymentManager.deployModuleAllServers('shell')" 
              src="/kame-house/img/other/cloud-up-down-green.png" alt="Deploy - All Servers" title="Deploy - All Servers"/>
          </td>
        </tr>        
      </table>
      
      <pre class="console-output tomcat-process-console-output"><div id="tomcat-process-status-val">Tomcat process status not available at the moment</div></pre>
      <span class="bold-kh">Tomcat Process: </span>
      <img class="img-btn-kh m-7-d-r-kh" onclick="deploymentManager.startTomcat()" 
        src="/kame-house/img/mplayer/play-green.png" alt="Start Tomcat" title="Start Tomcat"/>
      <img class="img-btn-kh" onclick="deploymentManager.stopTomcat()" 
        src="/kame-house/img/mplayer/stop.png" alt="Stop Tomcat" title="Stop Tomcat"/>
      <br><br>

    </div> <!-- tab-deployment -->

    <div id="tab-media" class="default-layout tab-groot-content p-7-d-kh w-50-pc-kh w-100-pc-m-kh">

      <br>
      <h4 class="h4-kh txt-l-d-kh txt-c-m-kh">Media</h4>
      <br>
      <div class="default-layout w-80-pc-kh w-100-pc-m-kh">
        <span class="bold-kh">Create all video playlists: </span>
        <img class="img-btn-kh m-7-d-r-kh" onclick="serverManager.createAllVideoPlaylists()" 
          src="/kame-house/img/mplayer/playlist-blue.png" alt="Create Video Playlists" title="Create Video Playlists"/>
        <br><br>
      </div>
      <p>This command can only be executed in the media server</p>

    </div> <!-- tab-media -->

    <div id="tab-power" class="tab-groot-content">

      <div class="default-layout p-7-d-kh w-40-pc-kh w-100-pc-m-kh">
      <br>
      <h5 class="h5-kh txt-c-m-kh">Power Management</h5>
      <br>
      <span class="bold-kh p-15-d-kh">Restart the server: </span>
      <img class="img-btn-kh m-7-d-r-kh" onclick="serverManager.confirmRebootServer()" 
        src="/kame-house/img/pc/shutdown-red.png" alt="Reboot" title="Reboot"/>

      <br><br>
      <p>If I need to schedule a shutdown or hibernate, I can do it from /kame-house's server management page</p>
      <br>
      </div>

    </div> <!-- tab-power -->

    <div id="tab-tail-log" class="default-layout tab-groot-content p-15-d-kh">

      <br>
      <h4 class="h4-kh txt-l-d-kh txt-c-m-kh">Tail Logs</h4>
      <div class="default-layout w-80-pc-kh w-100-pc-m-kh">
        <br>
        <p>Tail the logs of the current processes running in the server. Once tail log is started, you can switch between logs to tail and the number of lines without the need for stopping and starting</p>

        <div id="log-selector">
          <select class="select-kh-dark m-10-d-r-kh m-10-m-r-kh" id="tail-log-dropdown">
            <option value="common/logs/cat-create-all-video-playlists-log.sh">create-all-video-playlists</option>
            <option value="common/logs/cat-deploy-all-servers-log.sh">deploy-all-servers</option>
            <option value="common/logs/cat-deploy-java-web-kamehouse-log.sh" selected>deploy-java-web-kamehouse</option>
            <option value="common/logs/cat-git-pull-all-log.sh">git-pull-all</option>
            <option value="common/logs/cat-git-pull-all-all-servers-log.sh">git-pull-all-all-servers</option>
            <option value="common/logs/cat-httpd-log.sh">httpd</option>
            <option value="common/logs/cat-kamehouse-log.sh">kamehouse</option>
            <option value="common/logs/cat-tomcat-log.sh">tomcat</option>
          </select>
          <img id="toggle-tail-log-img"
            class="img-btn-kh m-10-d-r-kh" 
            onclick="tailLogManagerWrapper.toggleTailLog()" 
            src="/kame-house/img/mplayer/play-green.png"
            alt="Start Tail Log" title="Start Tail Log"/>
          <div id="number-of-lines">
            <span class="bold-kh p-15-d-kh">Number of lines: </span>
            <select class="select-kh-dark m-10-d-r-kh m-10-m-r-kh" id="tail-log-num-lines-dropdown">
              <option value="50" selected>50</option>
              <option value="150">150</option>
              <option value="350">350</option>
              <option value="500">500</option>
              <option value="1000">1000</option>
              <option value="1500">1500</option>
              <option value="2000">2000</option>
            </select>
          </div>
        </div>
      </div>
      <button id="tail-log-output-wrapper" class="collapsible-kh collapsible-kh-btn">Tail Log Output</button>
      <div class="collapsible-kh-content">
        <button class="btn-svg-scroll-down fl-r-d-kh"
          onclick="scrollToBottom('btn-tail-log-scroll-up')">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 6"><path d="M12 6H0l6-6z"/></svg>
        </button>
        <!-- pre and table need to be in the same line or it prints some extra lines -->
        <pre class="console-output"><table class="console-output-table">
            <caption class="hidden-kh">Tail Log Output</caption>
            <tr class="hidden-kh">
              <th scope="row">Tail Log Output</th>
            </tr>
            <tbody id="tail-log-output-table-body">
              <tr><td>Tail log not triggered yet...</td></tr>
            </tbody>
        </table></pre>
        <button class="btn-svg-scroll-up fl-r-d-kh" id="btn-tail-log-scroll-up" 
          onclick="scrollToTop('tail-log-output-wrapper')">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 6"><path d="M12 6H0l6-6z"/></svg>
        </button>
      </div>
    
    </div> <!-- tab-tail-log -->

  <div class="default-layout p-7-d-kh">
    <button id="command-output-wrapper" class="collapsible-kh collapsible-kh-btn">Command Output</button>
    <div class="collapsible-kh-content">
      <button class="btn-svg-scroll-down fl-r-d-kh"
        onclick="scrollToTop('btn-command-output-scroll-up')">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 6"><path d="M12 6H0l6-6z"/></svg>
      </button>
      
        <!-- pre and the divs need to be in the same line or it prints some extra lines -->
      <pre id="script-output-executing-wrapper" class="script-output-executing-wrapper hidden-kh"><div id="script-output-executing" class="txt-c-d-kh txt-c-m-kh"></div><br><div class="txt-c-d-kh txt-c-m-kh">Please wait...</div><div class="spinning-wheel"></div></pre>

      <!-- pre and table need to be in the same line or it prints some extra lines -->
      <pre id="script-output" class="console-output"><table class="console-output-table">
          <caption class="hidden-kh">Script Output</caption>
          <tr class="hidden-kh">
            <th scope="row">Script Output</th>
          </tr>
          <tbody id="script-output-table-body">
            <tr><td>No command executed yet...</td></tr>
          </tbody>
      </table></pre>
      <button class="btn-svg-scroll-up fl-r-d-kh" id="btn-command-output-scroll-up" 
        onclick="scrollToTop('command-output-wrapper')">
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 12 6"><path d="M12 6H0l6-6z"/></svg>
      </button>
    </div>
    <br>
    <div class="default-layout txt-c-d-kh txt-c-m-kh">
      <span id="debug-mode-button-wrapper"></span>
    </div>
  </div>
  <span id="debug-mode-wrapper"></span>
  <script src="/kame-house/js/snippets/kamehouse-modal.js"></script>
  <script src="/kame-house/js/admin/module-status-manager.js"></script>
  <script src="/kame-house/js/snippets/kamehouse-debugger.js"></script>
  <script src="/kame-house/js/snippets/sticky-back-to-top.js"></script>
  <script src="/kame-house-groot/js/admin/my-scripts/tail-log-manager.js"></script>
  <script src="/kame-house-groot/js/admin/my-scripts/script-executor.js"></script>
  <script src="/kame-house-groot/js/admin/server-manager/server-manager-index.js"></script>
</body>
</html>
