#!/usr/bin/awk -f 

###############################################################################
# Conventions for variables:
###############################################################################
# UPPER_CASE_UNDERSCORED: Global variables
# UPPER_CASE_RX: Reusable regex expressions
# camelCase: Script arguments
# camelCase_fn_: (ending with _fn_) function arguments
# camelCase_loc_: (ending with _loc_) local variables (defined in the function definition as arguments). As a convention, define them after the function arguments. Example: buildMessage()
# camelCase_rx_loc_: definitions of regex as local functions

###############################################################################
# Built-in variables:
###############################################################################
# FS: Field Separator. Default: space
# OFS: Output Field Separator. Default: space

###############################################################################
# Setup
###############################################################################
# Block of code called only once before processing any input lines
BEGIN {
  # Global constants:
  COL_BLUE="\033[1;34m";
  COL_BOLD="\033[1m";
  COL_CYAN="\033[1;36m";
  COL_NORMAL="\033[0;39m";
  COL_GREEN="\033[1;32m";
  COL_PURPLE="\033[1;35m";
  COL_RED="\033[1;31m";
  COL_YELLOW="\033[1;33m";

  DEFAULT_LOG_LEVEL_COLOR = COL_NORMAL;
  DEFAULT_LOG_LEVEL_NUM = 0;
  DEFAULT_HTTP_METHOD_COLOR=COL_CYAN;
  DEFAULT_HTTP_RESPONSE_CODE_COLOR=COL_CYAN;

  # Reusable regex expressions
  USERNAME_RX="[A-Za-z0-9\\-]*";
  # Date and time
  HH_MM_SS_RX="[0-9]{1,2}:[0-9]{2}:[0-9]{2}"; # 16:45:59 , 9:25:52
  HH_MM_SS_XXX_RX="[0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{3}"; # 16:45:59.325
  TZONE_RX="\\+[0-9]{4}";
  YYYY_MM_DD_RX="[0-9]{4}-[0-9]{2}-[0-9]{2}"; # 2020-10-15
  YEAR_RX="[0-9]{4}";
  Ddd_RX="[A-Z][a-z]{2}";
  Mmm_RX="[A-Z][a-z]{2}";
  # IP
  IPV4_RX="[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"; # 192.168.0.2
  IPV6_RX="[0-9a-zA-Z:]+"; # 0:0:0:0:0:0:0:1
  IPV4_OR_V6_RX="("IPV4_RX"|"IPV6_RX")";
  # HTTP Version
  HTTP_METHOD_RX="[A-Z]{3,9}";
  HTTP_VERSION_RX="HTTP\\/[0-9]\\.[0-9]";
  # Log level
  LOG_LEVEL_HTTPD_RX="(emerg|alert|crit|error|warn|notice|info|debug|trace([0-9])+)"
  LOG_LEVEL_JAVA_RX="(TRACE|DEBUG|INFO|WARN|ERROR)";
  LOG_LEVEL_TOMCAT_RX="(FINEST|FINER|FINE|INFO|WARN|WARNING|SEVERE)";

  # Global variables:
  LOG_LEVEL_NUM_TO_PRINT = DEFAULT_LOG_LEVEL_NUM;
  PRINT_LINE = "";

  parseArguments();
}

###############################################################################
# Main function
###############################################################################
# Main function called to process each line of input
function main() {
  init();
  matchPatterns();
}
main();

###############################################################################
# Pattern matchers
###############################################################################
# Match the current line to all the different patterns or print default without formatting
function matchPatterns() {
  # Tail header
  matchTailFileHeader();
  # Apache
  matchApacheAccessLog();
  matchApacheErrorLog();
  matchApacheSslRequestLog();
  # Kamehouse
  matchKamehouseLog();
  # Tomcat
  matchCatalinaOut();
  matchTomcatLocalhostAccessLog();
  # Default
  printDefault();
}

# Print file headers displayed by tail when tailing multiple files
function matchTailFileHeader(fileLine_rx_loc_) {
  # ==> /c/Users/nbrest/programs/apache-tomcat/logs/kameHouse.log <==
  # Format '==> FILE <=='
  fileLine_rx_loc_ = "^==> .* <==";
  if ($0 ~ fileLine_rx_loc_) {
    printColored(COL_RED);
  }
}

# Apache Httpd: access.log 
function matchApacheAccessLog(accessLogNoHttp_rx_loc_) {
  # Currently it's the same format as tomcat localhost_acces_log.YYYY-MM-DD.txt. If it differs in the future, implement it here.
  matchTomcatLocalhostAccessLog();

  # Windows: ::1 - - [10/Apr/2020:18:26:35 +1000] "-" 408 -
  # Format 'IP - - [DD/Mmm/YYYY:HH:MM:SS +9999] "-" 999'
  # Format 'IP - username [DD/Mmm/YYYY:HH:MM:SS +9999] "-" 999'
  accessLogNoHttp_rx_loc_ = "^"IPV4_OR_V6_RX" - "USERNAME_RX" \\[[0-9]{2}\\/"Mmm_RX"\\/"YEAR_RX":"HH_MM_SS_RX" "TZONE_RX"\\] \"-\" [0-9]+.*";
  if ($0 ~ accessLogNoHttp_rx_loc_){ 
    printTomcatLocalhostAccessLog();
  }
}

# Apache Httpd: error.log 
function matchApacheErrorLog(errorLog_rx_loc_) {
  # Windows: [Thu Feb 13 20:17:46.199682 2020] [ssl:warn] [pid 7948:tid 224] AH01909: localhost:443:0 server certificate does NOT include an ID which matches the server name
  # Format: '[Ddd Mmm DD HH:MM:SS.XXXXXX YYYY] [MODULE:LOG_LEVEL] [pid 9999:tid 999] MESSAGE'
  errorLog_rx_loc_ = "^\\["Ddd_RX" "Mmm_RX" [0-9]{2} "HH_MM_SS_RX"\\.[0-9]{6} "YEAR_RX"\\] \\[.*:"LOG_LEVEL_HTTPD_RX"\\] \\[pid [0-9]*(:tid [0-9]*){0,1}\\].*";
  if ($0 ~ errorLog_rx_loc_){ 
    printApacheErrorLog();
  }
}

# Apache Httpd: ssl_request.log 
function matchApacheSslRequestLog(sslRequestLog_rx_loc_) {
  # [07/Apr/2020:22:19:38 +1000] ::1 TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384 "GET /kame-house/api/ws/vlc-player/status/923/4cey2f5b/websocket HTTP/1.1" -
  # [09/Apr/2020:21:29:52 +1000] 192.168.0.100 TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384 "GET / HTTP/1.1" 28544  
  # [07/Apr/2020:22:19:37 +1000] ::1 TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384 "GET /kame-house/img/other/sync-btn-info.png HTTP/2.0" 1041
  # [08/Apr/2020:21:26:47 +1000] 192.168.0.100 - - "GET / HTTP/1.0" 853
  # Format: '[DD/Mmm/YYYY:HH:MM:SS +9999] IP .* .* "HTTP_METHOD URL HTTP/VERSION".*'
  sslRequestLog_rx_loc_ = "^\\[[0-9]{2}\\/"Mmm_RX"\\/"YEAR_RX":"HH_MM_SS_RX" "TZONE_RX"\\] "IPV4_OR_V6_RX" .* .* \""HTTP_METHOD_RX" .*"HTTP_VERSION_RX"\".*";
  if ($0 ~ sslRequestLog_rx_loc_){ 
    printApacheSslRequestLog();
  }  
}

# Kamehouse: java log entries
function matchKamehouseLog(kamehouse_rx_loc_) {
  # Kamehouse: kameHouse.log
  # 2020-04-11 11:53:18.641 [http-bio-9090-exec-28] TRACE c.n.k.a.c.SessionStatusController - /api/v1/session/status (GET)
  # Format: 'YYYY-MM-DD HH:MM:SS.XXX [THREAD] LOG_LEVEL CLASS - MESSAGE'
  kamehouse_rx_loc_ = "^"YYYY_MM_DD_RX" "HH_MM_SS_XXX_RX" \\[.*\\] "LOG_LEVEL_JAVA_RX" .* - .*";
  if ($0 ~ kamehouse_rx_loc_) {
    printKamehouseJavaLog();
  }
}

# Tomcat: catalina.out
function matchCatalinaOut(kamehouse_rx_loc_, logLevelEntry_rx_loc_, dateWinEntry_rx_loc_, dateLinEntry_rx_loc_, dateLinEntry_2_rx_loc_) {
  # kameHouse.log entries in catalina.out
  # Linux: 2020-04-05 18:21:39 [localhost-startStop-1] INFO o.s.c.e.EhCacheManagerFactoryBean - Shutting down EhCache CacheManager
  # Format: 'YYYY-MM-DD HH:MM:SS [THREAD] LOG_LEVEL CLASS - MESSAGE'
  kamehouse_rx_loc_ = "^"YYYY_MM_DD_RX" "HH_MM_SS_RX" \\[.*\\] "LOG_LEVEL_JAVA_RX" .* - .*";
  if ($0 ~ kamehouse_rx_loc_) {
    printKamehouseJavaLog();
  }

  # Windows: INFO: Destroying ProtocolHandler ["http-bio-9090"]
  # Format: 'LOG_LEVEL: MESSAGE'
  logLevelEntry_rx_loc_ = "^"LOG_LEVEL_TOMCAT_RX": .*";
  if ($0 ~ logLevelEntry_rx_loc_) {
    printCatalinaOutLogLevelEntry();
  }
  
  # Windows: Apr 05, 2020 6:21:39 PM org.apache.coyote.AbstractProtocol destroy
  # Format 'Mmm DD, YYYY {H}H:MM:SS (AM|PM) CLASS MESSAGE'
  dateWinEntry_rx_loc_ = "^"Mmm_RX" [0-9]{2}, "YEAR_RX" "HH_MM_SS_RX" (AM|PM) .*";
  if ($0 ~ dateWinEntry_rx_loc_) {
    printCatalinaOutDateWinEntry();
  }

  # Linux: Sat Apr 11 11:49:03 AEST 2020 WARN: Establishing SSL connection without server's ...
  # Format: 'Ddd Mmm DD HH:MM:SS ZONE YYYY LOG_LEVEL: MESSAGE'
  dateLinEntry_rx_loc_ = "^"Ddd_RX" "Mmm_RX" [0-9]{2} "HH_MM_SS_RX" [A-Z]{3,5} "YEAR_RX" "LOG_LEVEL_TOMCAT_RX":.*";
  if ($0 ~ dateLinEntry_rx_loc_) {
    printCatalinaOutDateLinEntry();
  }

  # Linux: 08-Apr-2020 19:09:14.988 SEVERE [localhost-startStop-1] org.apache.catalina.core.StandardContext.startInternal One or more listeners failed to start ...
  # Format: 'DD-Mmm-YYYY HH:MM:SS.XXX LOG_LEVEL [THREAD] CLASS MESSAGE'
  dateLinEntry_2_rx_loc_ = "^[0-9]{2}-"Mmm_RX"-"YEAR_RX" "HH_MM_SS_RX"\\.[0-9]{3} "LOG_LEVEL_TOMCAT_RX" \\[.*\\] .* .*";
  if ($0 ~ dateLinEntry_2_rx_loc_) {
    printCatalinaOutDateLinEntry2();
  }
}

# Tomcat: localhost_acces_log.YYYY-MM-DD.txt
function matchTomcatLocalhostAccessLog(localhostAccessLog_rx_loc_) {
  # 127.0.0.1 - - [11/Apr/2020:11:53:18 +1000] "GET /kame-house/ HTTP/1.1" 200 1936
  # ::1 - - [11/Apr/2020:11:53:18 +1000] "GET /kame-house/ HTTP/1.1" 200 1936
  # 0:0:0:0:0:0:0:1 - - [11/Apr/2020:11:52:50 +1000] "GET /kame-house/img/pc/server-gray.png HTTP/1.1" 200 441
  # Format: 'IP - - [DD/Mmm/YYYY:HH:MM:SS +9999] "HTTP_METHOD URL HTTP_VERSION" HTTP_RETURN_CODE BYTES'
  localhostAccessLog_rx_loc_ = "^"IPV4_OR_V6_RX" - "USERNAME_RX" \\[[0-9]{2}\\/"Mmm_RX"\\/"YEAR_RX":"HH_MM_SS_RX" "TZONE_RX"\\] \""HTTP_METHOD_RX" .*"HTTP_VERSION_RX"\".*";
  if ($0 ~ localhostAccessLog_rx_loc_){ 
    printTomcatLocalhostAccessLog();
  }
}

###############################################################################
# Utility functions
###############################################################################
# Reset/init default values for each line:
function init() {
  PRINT_LINE = "";
}

# Parse the command line arguments
function parseArguments() {
  # Script arguments
  # logLevel=[trace|debug|info|warn|error]
  LOG_LEVEL_NUM_TO_PRINT = getLogLevelNumber(logLevel);
  if (LOG_LEVEL_NUM_TO_PRINT == DEFAULT_LOG_LEVEL_NUM) {
    # logLevel parameter not set. Set to print everything by default.
    LOG_LEVEL_NUM_TO_PRINT = 5;
  }
}

# Add a column to the print line to print and the default output field separator
function addColumnToPrintLine(column_fn_, color_fn_) {
  addColumnToPrintLineNoOFS(column_fn_, color_fn_);
  PRINT_LINE = PRINT_LINE OFS;
}

# Add a column to the print line to print without the default output field separator
function addColumnToPrintLineNoOFS(column_fn_, color_fn_) {
  if (column_fn_ != "") {
    PRINT_LINE = PRINT_LINE color_fn_ column_fn_; 
  }
}

# Build a message with the remaining columns starting with the start column index passed
function buildMessage(startColumnIndex_fn_, message_loc_) {
  message_loc_ = ""; 
  for (i = startColumnIndex_fn_ ; i <= NF ; i++) { 
    message_loc_ = message_loc_ OFS $i;
  }
  return message_loc_;
}

###############################################################################
# Http Methods and Response Code functions
###############################################################################

# Get the http method color for the specified http method
function getHttpMethodColor(httpMethod_fn_, httpMethodColor_loc_) {
  httpMethodColor_loc_ = DEFAULT_HTTP_METHOD_COLOR;
  httpMethod_fn_ = toupper(httpMethod_fn_);
  if (httpMethod_fn_ == "GET") {
    httpMethodColor_loc_ = COL_GREEN; 
  }
  if (httpMethod_fn_ == "POST") {
    httpMethodColor_loc_ = COL_YELLOW;
  }
  if (httpMethod_fn_ == "PUT") { 
    httpMethodColor_loc_ = COL_BLUE; 
  }
  if (httpMethod_fn_ == "DELETE") {
    httpMethodColor_loc_ = COL_RED;
  } 
  return httpMethodColor_loc_;
}

# Get the http response code color for the specified http response code
function getHttpResponseCodeColor(httpResponseCode_fn_, httpResponseCodeColor_loc_) {
  httpResponseCodeColor_loc_ = DEFAULT_HTTP_RESPONSE_CODE_COLOR; 
  if (httpResponseCode_fn_ >= 200) {
    httpResponseCodeColor_loc_ = COL_GREEN;
  } 
  if (httpResponseCode_fn_ >= 300) { 
    httpResponseCodeColor_loc_ = COL_YELLOW; 
  }
  if (httpResponseCode_fn_ >= 400) {
    httpResponseCodeColor_loc_ = COL_RED;
  }
  if (httpResponseCode_fn_ >= 500) {
    httpResponseCodeColor_loc_ = COL_RED; 
  }
  return httpResponseCodeColor_loc_;
}

# Get the log level mumeric value to decide to print or skip, mapped from the http response code
function getLogLevelNumberFromHttpResponseCode(httpResponseCode_fn_, logLevelNumberFromHttpResponseCode_loc_) {
  logLevelNumberFromHttpResponseCode_loc_ = DEFAULT_LOG_LEVEL_NUM;
  if (httpResponseCode_fn_ >= 200) {
    # Map 2XX http response codes to INFO log level
    logLevelNumberFromHttpResponseCode_loc_ = 3;
  } 
  if (httpResponseCode_fn_ >= 300) { 
    # Map 3XX http response code to WARN log level
    logLevelNumberFromHttpResponseCode_loc_ = 2; 
  }
  if (httpResponseCode_fn_ >= 400) {
    # Map 4XX http response code to ERROR log level
    logLevelNumberFromHttpResponseCode_loc_ = 1;
  }
  if (httpResponseCode_fn_ >= 500) {
    # Map 5XX http response code to ERROR log level
    logLevelNumberFromHttpResponseCode_loc_ = 1; 
  }
  return logLevelNumberFromHttpResponseCode_loc_;
}

# Check if I should print or skip this line, based on the http response code mapped to the log level.
function checkHttpResponseCodeToPrint(httpResponseCodeMappedToLogLevel_fn_) {
  if (httpResponseCodeMappedToLogLevel_fn_ > LOG_LEVEL_NUM_TO_PRINT) {
    # current log level is higher than the log level to print, skipping this line
    next
  }
}

###############################################################################
# Log Level functions
###############################################################################
# Get the log level numeric value for the specified log level
function getLogLevelNumber(logLevel_fn_, logLevelNumber_loc_) { 
  logLevelNumber_loc_ = DEFAULT_LOG_LEVEL_NUM;
  if (isLogLevelError(logLevel_fn_)) {
    logLevelNumber_loc_ = 1;
  } 
  if (isLogLevelWarn(logLevel_fn_)) {
    logLevelNumber_loc_ = 2;
  }
  if (isLogLevelInfo(logLevel_fn_)) {
    logLevelNumber_loc_ = 3;
  }
  if (isLogLevelDebug(logLevel_fn_)) {
    logLevelNumber_loc_ = 4;
  }
  if (isLogLevelTrace(logLevel_fn_)) { 
    logLevelNumber_loc_ = 5;
  }
  return logLevelNumber_loc_;
}

# Get the log level color for the specified log level. Considers Kamehouse, Apache httpd and Tomcat log levels.
function getLogLevelColor(logLevel_fn_, logLevelColor_loc_) {
  logLevelColor_loc_ = DEFAULT_LOG_LEVEL_COLOR;
  if (isLogLevelError(logLevel_fn_)) {
    logLevelColor_loc_ = COL_RED;
  } 
  if (isLogLevelWarn(logLevel_fn_)) {
    logLevelColor_loc_ = COL_YELLOW;
  }
  if (isLogLevelInfo(logLevel_fn_)) {
    logLevelColor_loc_ = COL_GREEN; 
  }
  if (isLogLevelDebug(logLevel_fn_)) {
    logLevelColor_loc_ = COL_CYAN;
  }
  if (isLogLevelTrace(logLevel_fn_)) { 
    logLevelColor_loc_ = COL_BLUE; 
  }
  return logLevelColor_loc_;
}

function isLogLevelError(logLevel_fn_) {
  logLevel_fn_ = toupper(logLevel_fn_);
  if (logLevel_fn_ == "ERROR" || logLevel_fn_ == "SEVERE" || logLevel_fn_ == "EMERG" || logLevel_fn_ == "ALERT" || logLevel_fn_ == "CRIT") {
    return "true";
  } else {
    return ""; # Empty strings and 0 are considered false. Anything else true. There's no boolean values
  }  
}

function isLogLevelWarn(logLevel_fn_) {
  logLevel_fn_ = toupper(logLevel_fn_);
  if (logLevel_fn_ == "WARN"|| logLevel_fn_ == "WARNING") {
    return "true";
  } else {
    return "";
  }  
}

function isLogLevelInfo(logLevel_fn_) {
  logLevel_fn_ = toupper(logLevel_fn_);
  if (logLevel_fn_ == "INFO" || logLevel_fn_ == "NOTICE") {
    return "true";
  } else {
    return "";
  }  
}

function isLogLevelDebug(logLevel_fn_) {
  logLevel_fn_ = toupper(logLevel_fn_);
  if (logLevel_fn_ == "DEBUG" || logLevel_fn_ == "FINE") {
    return "true";
  } else {
    return "";
  }  
}

function isLogLevelTrace(logLevel_fn_) {
  logLevel_fn_ = toupper(logLevel_fn_);
  if (logLevel_fn_ == "TRACE" || logLevel_fn_ == "FINER" || logLevel_fn_ == "FINEST") {
    return "true";
  } else {
    return "";
  }  
}

# Check if I should print or skip this line, based on the log level
function checkLogLevelToPrint(logLevelNumber_fn_) {
  if (logLevelNumber_fn_ > LOG_LEVEL_NUM_TO_PRINT) {
    # current log level is higher than the log level to print, skipping this line
    next
  }
}

###############################################################################
# Formatting and printing functions
###############################################################################

# Print input without formatting if no other pattern matched.
function printDefault() {
  printColored(COL_NORMAL);
}

# Print the line in the specified color
function printColored(color_fn_) {
  print color_fn_ $0 COL_NORMAL;
  next;
}

# Print kamehouse java log 
function printKamehouseJavaLog(date_loc_, time_loc_, thread_loc_, logLevel_loc_, logLevelColor_loc_, logLevelNumber_loc_, class_loc_, dash_loc_, message_loc_) {
  # LOG format: 'date time [thread] logLevel class - message'
  PRINT_LINE = "";
  date_loc_ = $1;
  time_loc_ = $2;
  thread_loc_ = $3;
  logLevel_loc_ = $4;
  class_loc_ = $5;
  dash_loc_ = $6
  message_loc_ = buildMessage(7); 
  
  logLevelColor_loc_ = getLogLevelColor(logLevel_loc_);
  logLevelNumber_loc_ = getLogLevelNumber(logLevel_loc_);
  checkLogLevelToPrint(logLevelNumber_loc_);

  addColumnToPrintLine(date_loc_, COL_CYAN);
  addColumnToPrintLine(time_loc_, COL_CYAN);
  addColumnToPrintLine(thread_loc_, COL_PURPLE);
  addColumnToPrintLine(logLevel_loc_, logLevelColor_loc_);
  addColumnToPrintLine(class_loc_, COL_PURPLE);
  addColumnToPrintLineNoOFS(dash_loc_, COL_BLUE);
  addColumnToPrintLineNoOFS(message_loc_, COL_NORMAL);

  print PRINT_LINE
  next
}

# Print localhost_acces_log.YYYY-MM-DD.txt (and apache access.log)
function printTomcatLocalhostAccessLog(ip_loc_, dash_loc_, datetime_loc_, tzone_loc_, httpMethod_loc_, url_loc_, httpVersion_loc_, httpReturnCode_loc_, bytesReturned_loc_, httpMethodFormatted_loc_, httpMethodColor_loc_, httpReturnCodeColor_loc_, logLevelNumber_loc_) {
  # Format: 'IP - - [DD/Mmm/YYYY:HH:MM:SS +9999] "HTTP_METHOD URL HTTP_VERSION" HTTP_RETURN_CODE BYTES'
  PRINT_LINE = "";
  ip_loc_ = $1; # IP
  dash_loc_ = $2" "$3; # - -
  datetime_loc_ = $4; # [DD/Mmm/YYYY:HH:MM:SS
  tzone_loc_ = $5; #  +9999]
  httpMethod_loc_ = $6 # "HTTP_METHOD
  url_loc_ = $7 # URL
  httpVersion_loc_ = $8 # HTTP_VERSION"
  httpReturnCode_loc_ = $9 # HTTP_RETURN_CODE
  bytesReturned_loc_ = $10 # BYTES

  httpMethodFormatted_loc_ = substr(httpMethod_loc_, 2);
  httpMethodColor_loc_ = getHttpMethodColor(httpMethodFormatted_loc_);
  httpReturnCodeColor_loc_ = getHttpResponseCodeColor(httpReturnCode_loc_);
  logLevelNumber_loc_ = getLogLevelNumberFromHttpResponseCode(httpReturnCode_loc_);
  checkLogLevelToPrint(logLevelNumber_loc_);

  addColumnToPrintLine(ip_loc_, COL_BLUE); 
  addColumnToPrintLine(dash_loc_, COL_PURPLE);
  addColumnToPrintLine(datetime_loc_, COL_CYAN); 
  addColumnToPrintLine(tzone_loc_, COL_CYAN); 
  addColumnToPrintLine(httpMethod_loc_, httpMethodColor_loc_); 
  addColumnToPrintLine(url_loc_, COL_NORMAL); 
  addColumnToPrintLine(httpVersion_loc_, httpMethodColor_loc_); 
  addColumnToPrintLine(httpReturnCode_loc_, httpReturnCodeColor_loc_); 
  addColumnToPrintLine(bytesReturned_loc_, COL_PURPLE);  

  print PRINT_LINE
  next
}

# Print apache error.log
function printApacheErrorLog(datetime_loc_, moduleAndLogLevel_loc_, pid_loc_, message_loc_, logLevel_loc_, logLevelColor_loc_, logLevelNumber_loc_, start_loc_, end_loc_) {
  # Format: '[Ddd Mmm DD HH:MM:SS.XXXXXX YYYY] [MODULE:LOG_LEVEL] [pid 9999:tid 999] MESSAGE'
  PRINT_LINE = "";
  datetime_loc_ = $1" "$2" "$3" "$4" "$5; # [Ddd Mmm HH:MM:SS.XXXXXX YYYY]
  moduleAndLogLevel_loc_ = $6; # [MODULE:LOG_LEVEL]
  pid_loc_ = $7" "$8" "$9; # [pid 9999:tid 999]
  message_loc_ = buildMessage(10);   

  start_loc_ = index(moduleAndLogLevel_loc_,":") + 1;
  end_loc_ = index(moduleAndLogLevel_loc_,"]") - start_loc_;
  logLevel_loc_ = substr(moduleAndLogLevel_loc_, start_loc_, end_loc_);
  logLevelColor_loc_ = getLogLevelColor(logLevel_loc_);
  logLevelNumber_loc_ = getLogLevelNumber(logLevel_loc_);
  checkLogLevelToPrint(logLevelNumber_loc_);

  addColumnToPrintLine(datetime_loc_, COL_CYAN); 
  addColumnToPrintLine(moduleAndLogLevel_loc_, logLevelColor_loc_);
  addColumnToPrintLineNoOFS(pid_loc_, COL_PURPLE); 
  #TODO: Fix logic for when I don't have tid
  addColumnToPrintLine(message_loc_, COL_NORMAL);

  print PRINT_LINE
  next
}

# Print apache ssl_request.log
function printApacheSslRequestLog(datetime_loc_, ip_loc_, tlsVersion_loc_, tlsKeys_loc_, httpMethod_loc_, url_loc_, httpVersion_loc_, bytes_loc_, message_loc_, httpMethodFormatted_loc_, httpMethodColor_loc_) {
  # Format: '[DD/Mmm/YYYY:HH:MM:SS +9999] IP .* .* "HTTP_METHOD URL HTTP/VERSION" BYTES.*'
  PRINT_LINE = "";
  datetime_loc_ = $1" "$2; # [DD/Mmm/YYYY:HH:MM:SS +9999]
  ip_loc_ = $3; # IP
  tlsVersion_loc_ = $4 # .*
  tlsKeys_loc_ = $5 # .*
  httpMethod_loc_ = $6 # "HTTP_METHOD
  url_loc_ = $7 # URL
  httpVersion_loc_ = $8 # HTTP/VERSION"
  bytes_loc_ = $9 # BYTES"
  message_loc_ = buildMessage(10);   

  httpMethodFormatted_loc_ = substr(httpMethod_loc_, 2);
  httpMethodColor_loc_ = getHttpMethodColor(httpMethodFormatted_loc_);

  addColumnToPrintLine(datetime_loc_, COL_CYAN); 
  addColumnToPrintLine(ip_loc_, COL_BLUE);
  addColumnToPrintLine(tlsVersion_loc_, COL_PURPLE);  
  addColumnToPrintLine(tlsKeys_loc_, COL_PURPLE);
  addColumnToPrintLine(httpMethod_loc_, httpMethodColor_loc_); 
  addColumnToPrintLine(url_loc_, COL_NORMAL);
  addColumnToPrintLine(httpVersion_loc_, httpMethodColor_loc_);  
  addColumnToPrintLineNoOFS(bytes_loc_, COL_RED);
  addColumnToPrintLine(message_loc_, COL_NORMAL); 

  print PRINT_LINE
  next
}

# Print catalina.out entry
function printCatalinaOutLogLevelEntry(logLevel_loc_, message_loc_, logLevelFormatted_loc_, logLevelColor_loc_, logLevelNumber_loc_, end_loc_) {
  # Format: 'LOG_LEVEL: MESSAGE'
  PRINT_LINE = "";
  logLevel_loc_ = $1; # LOG_LEVEL:
  message_loc_ = buildMessage(2);   

  end_loc_ = index(logLevel_loc_,":") - 1;
  logLevelFormatted_loc_ = substr(logLevel_loc_, 0, end_loc_);
  logLevelColor_loc_ = getLogLevelColor(logLevelFormatted_loc_);
  logLevelNumber_loc_ = getLogLevelNumber(logLevelFormatted_loc_);
  checkLogLevelToPrint(logLevelNumber_loc_);

  addColumnToPrintLineNoOFS(logLevel_loc_, logLevelColor_loc_);
  addColumnToPrintLine(message_loc_, COL_NORMAL);

  print PRINT_LINE
  next
}

# Print catalina.out entry
function printCatalinaOutDateWinEntry(datetime_loc_, class_loc_, message_loc_) {
  # Format 'Mmm DD, YYYY {H}H:MM:SS (AM|PM) CLASS MESSAGE'
  PRINT_LINE = "";
  datetime_loc_ = $1" "$2" "$3" "$4" "$5; # Mmm DD, YYYY {H}H:MM:SS (AM|PM)
  class_loc_ = $6; # CLASS
  message_loc_ = buildMessage(7);   

  addColumnToPrintLine(datetime_loc_, COL_CYAN); 
  addColumnToPrintLineNoOFS(class_loc_, COL_PURPLE);
  addColumnToPrintLine(message_loc_, COL_NORMAL); 

  print PRINT_LINE
  next
}

# Print catalina.out entry
function printCatalinaOutDateLinEntry(datetime_loc_, logLevel_loc_, message_loc_, logLevelFormatted_loc_, logLevelColor_loc_, logLevelNumber_loc_, end_loc_) {
  # Format: 'Ddd Mmm DD HH:MM:SS ZONE YYYY LOG_LEVEL: MESSAGE'
  PRINT_LINE = "";
  datetime_loc_ = $1" "$2" "$3" "$4" "$5" "$6; # Ddd Mmm DD HH:MM:SS ZONE YYYY
  logLevel_loc_ = $7; # LOG_LEVEL:
  message_loc_ = buildMessage(8);   

  end_loc_ = index(logLevel_loc_,":") - 1;
  logLevelFormatted_loc_ = substr(logLevel_loc_, 0, end_loc_);
  logLevelColor_loc_ = getLogLevelColor(logLevelFormatted_loc_);
  logLevelNumber_loc_ = getLogLevelNumber(logLevelFormatted_loc_);
  checkLogLevelToPrint(logLevelNumber_loc_);

  addColumnToPrintLine(datetime_loc_, COL_CYAN); 
  addColumnToPrintLineNoOFS(logLevel_loc_, logLevelColor_loc_);
  addColumnToPrintLine(message_loc_, COL_NORMAL); 

  print PRINT_LINE
  next
}

# Print catalina.out entry
function printCatalinaOutDateLinEntry2(datetime_loc_, class_loc_, message_loc_, logLevelColor_loc_, logLevelNumber_loc_, end_loc_) {
  # Format: 'DD-Mmm-YYYY HH:MM:SS.XXX LOG_LEVEL [THREAD] CLASS MESSAGE'
  PRINT_LINE = "";
  datetime_loc_ = $1" "$2; # DD-Mmm-YYYY HH:MM:SS.XXX
  logLevel_loc_ = $3; # LOG_LEVEL
  thread_loc_ = $4; # [THREAD] 
  class_loc_ = $5; # CLASS
  message_loc_ = buildMessage(6);   

  logLevelColor_loc_ = getLogLevelColor(logLevel_loc_);
  logLevelNumber_loc_ = getLogLevelNumber(logLevel_loc_);
  checkLogLevelToPrint(logLevelNumber_loc_);

  addColumnToPrintLine(datetime_loc_, COL_CYAN);
  addColumnToPrintLine(logLevel_loc_, logLevelColor_loc_);
  addColumnToPrintLine(thread_loc_, COL_PURPLE);
  addColumnToPrintLineNoOFS(class_loc_, COL_GREEN);
  addColumnToPrintLine(message_loc_, COL_NORMAL); 

  print PRINT_LINE
  next
}