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

  <title>exec-script</title>

  <link rel="shortcut icon" href="/kame-house-groot/favicon.ico" type="image/x-icon" />
  <script src="/kame-house/lib/js/jquery-2.0.3.min.js"></script>
  <script src="/kame-house/js/global.js"></script>
  <script src="/kame-house-groot/js/global.js"></script>
  <link rel="stylesheet" href="/kame-house/lib/css/bootstrap.min.css" />
  <link rel="stylesheet" href="/kame-house/css/global.css" />
  <link rel="stylesheet" href="/kame-house-groot/css/global.css" />
  <link rel="stylesheet" href="/kame-house-groot/css/admin/my-scripts.css" />
</head>

<body>
  <div id="groot-menu-wrapper"></div>
  <div class="banner-wrapper">
    <div id="banner" class="fade-in-out-15s banner-fuji">
      <div class="default-layout banner-text">
        <h1>Execute Script</h1>
        <div id="banner-server-name"></div>
        <br>
        <div id="banner-script-status">not running</div>
      </div>
    </div>
  </div>
  <div class="default-layout">
    <br>
    <p class="p-15-m-kh">Executes the specified script from my-scripts in my
      kame-house server and displays the console output</p>
    <table id="script-table"
      class="table table-bordered-kh table-responsive-kh table-responsive bg-darker-kh">
      <tr>
        <td>Server Name:</td>
        <td id="st-server-name"></td>
      </tr>
      <tr>
        <td>Script Name:</td>
        <td id="st-script-name"></td>
      </tr>
      <tr>
        <td>Script Args:</td>
        <td id="st-script-args"></td>
      </tr>
      <tr>
        <td>Execution Start Date:</td>
        <td id="st-script-exec-start-date"></td>
      </tr>
      <tr>
        <td>Execution End Date:</td>
        <td id="st-script-exec-end-date"></td>
      </tr>
    </table>
    <h4 id="script-output-header" class="hidden-kh">Script Output</h4>

    <!-- pre and the divs need to be in the same line or it prints some extra lines -->
    <pre id="script-output-executing-wrapper" class="script-output-executing-wrapper hidden-kh"><div id="script-output-executing" class="txt-c-d-kh txt-c-m-kh"></div><br><div class="txt-c-d-kh txt-c-m-kh">Please wait...</div><div class="spinning-wheel"></div></pre>

    <!-- pre and table need to be in the same line or it prints some extra lines -->
    <pre id="script-output" class="console-output hidden-kh"><table class="console-output-table">
        <caption class="hidden-kh">Script Output</caption>
        <tr class="hidden-kh">
          <th scope="row">Script Output</th>
        </tr>
        <tbody id="script-output-table-body"></tbody>
      </table></pre>

    <img id="btn-execute-script"
      class="btn-img m-50-d-l-kh m-50-m-l-kh m-25-d-r-kh m-25-m-l-kh"
      onclick="scriptExecutor.executeFromUrlParams()" src="/kame-house/img/mplayer/play.png"
      alt="Execute Script" title="Execute Script" />
    <img id="btn-download-script-output" class="btn-img hidden-kh"
      onclick="scriptExecutor.downloadBashScriptOutput()"
      src="/kame-house/img/other/download-blue.png" alt="Download Output"
      title="Download Output" />
    <img class="btn-img m-50-d-l-kh m-50-m-l-kh m-25-d-r-kh m-25-m-l-kh fl-r-d-kh"
      onclick="scrollToTop()"
      src="/kame-house/img/other/back-to-top.png"
      alt="Back To Top" title="Back To Top" />

  </div>
  <script src="/kame-house-groot/js/admin/my-scripts/script-executor.js"></script>
  <script src="/kame-house-groot/js/admin/my-scripts/exec-script.js"></script>
  <script src="/kame-house/js/snippets/sticky-back-to-top.js"></script>
</body>

</html>