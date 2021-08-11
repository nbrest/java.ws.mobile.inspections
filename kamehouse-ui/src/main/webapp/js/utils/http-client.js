/**
 * HttpClient object to perform http calls.
 * 
 * Dependencies: logger.
 * 
 * @author nbrest
 */
function HttpClient() {

  this.get = get;
  this.put = put;
  this.post = post;
  this.delete = deleteHttp;
  this.getUrlEncodedHeaders = getUrlEncodedHeaders;
  this.getApplicationJsonHeaders = getApplicationJsonHeaders;

  /** Execute an http GET request.
   * Implement and pass successCallback(responseBody, responseCode, responseDescription) 
   * and errorCallback(responseBody, responseCode, responseDescription) */
  function get(url, requestHeaders, successCallback, errorCallback, data) {
    logger.trace(arguments.callee.name);
    httpRequest("GET", url, requestHeaders, null, successCallback, errorCallback, data)
  }

  /** Execute an http PUT request.
   * Implement and pass successCallback(responseBody, responseCode, responseDescription) 
   * and errorCallback(responseBody, responseCode, responseDescription) */
  function put(url, requestHeaders, requestBody, successCallback, errorCallback, data) {
    logger.trace(arguments.callee.name);
    httpRequest("PUT", url, requestHeaders, requestBody, successCallback, errorCallback, data)
  }

  /** Execute an http POST request.
   * Implement and pass successCallback(responseBody, responseCode, responseDescription) 
   * and errorCallback(responseBody, responseCode, responseDescription) */
  function post(url, requestHeaders, requestBody, successCallback, errorCallback, data) {
    logger.trace(arguments.callee.name);
    httpRequest("POST", url, requestHeaders, requestBody, successCallback, errorCallback, data)
  }

  /** Execute an http DELETE request.
   * Implement and pass successCallback(responseBody, responseCode, responseDescription) 
   * and errorCallback(responseBody, responseCode, responseDescription) */
  function deleteHttp(url, requestHeaders, requestBody, successCallback, errorCallback, data) {
    logger.trace(arguments.callee.name);
    httpRequest("DELETE", url, requestHeaders, requestBody, successCallback, errorCallback, data)
  }

  /** Execute an http request with the specified http method. 
   * Implement and pass successCallback(responseBody, responseCode, responseDescription) 
   * and errorCallback(responseBody, responseCode, responseDescription)
   * Don't call this method directly, instead call the wrapper get(), post(), put(), delete() */
  function httpRequest(httpMethod, url, requestHeaders, requestBody, successCallback, errorCallback, data) {
    if (isNullOrUndefined(requestBody)) {
      $.ajax({
        type: httpMethod,
        url: url,
        headers: requestHeaders,
        success: (data, status, xhr) => processSuccess(data, status, xhr, successCallback, data),
        error: (jqXhr, textStatus, errorMessage) => processError(jqXhr, textStatus, errorMessage, errorCallback, data)
      });
    } else {
      $.ajax({
        type: httpMethod,
        url: url,
        data: JSON.stringify(requestBody),
        headers: requestHeaders,
        success: (data, status, xhr) => processSuccess(data, status, xhr, successCallback, data),
        error: (jqXhr, textStatus, errorMessage) => processError(jqXhr, textStatus, errorMessage, errorCallback, data)
      });
    }
  }

  /** Process a successful response from the api call */
  function processSuccess(data, status, xhr, successCallback, data) {
    /**
     * data: response body
     * status: success/error
     * xhr: {
     *    readyState: 4
     *    responseText: response body as text
     *    responseJson: response body as json
     *    status: numeric status code
     *    statusText: status code as text (success/error)
     * }
     */
    let responseBody = data;
    let responseCode = xhr.status;
    let responseDescription = xhr.statusText;
    successCallback(responseBody, responseCode, responseDescription, data);
  }

  /** Process an error response from the api call */
  function processError(jqXhr, textStatus, errorMessage, errorCallback, data) {
     /**
      * jqXhr: {
      *    readyState: 4
      *    responseText: response body as text
      *    status: numeric status code
      *    statusText: status code as text (success/error)
      * }
      * textStatus: response body
      * errorMessage: (so far came empty, might have the response body)
      */
     let responseBody = jqXhr.responseText;
     let responseCode = jqXhr.status;
     let responseDescription = jqXhr.statusText;
     logger.error(JSON.stringify(jqXhr));
     errorCallback(responseBody, responseCode, responseDescription, data);
  }

  /** Get request headers object with Url Encoded content type. */
  function getUrlEncodedHeaders() {
    let requestHeaders = {};
    requestHeaders.Accept = '*/*';
    requestHeaders['Content-Type'] = "application/x-www-form-urlencoded";
    logger.trace("request headers: " + JSON.stringify(requestHeaders));
    return requestHeaders;
  }

  /** Get request headers object with application json content type. */
  function getApplicationJsonHeaders() {
    let requestHeaders = {};
    requestHeaders.Accept = '*/*';
    requestHeaders['Content-Type'] = 'application/json';
    logger.trace("request headers: " + JSON.stringify(requestHeaders));
    return requestHeaders;
  }
}
