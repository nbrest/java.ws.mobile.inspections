package com.nicobrest.kamehouse.tennisworld.service;

import com.nicobrest.kamehouse.commons.exception.KameHouseBadRequestException;
import com.nicobrest.kamehouse.commons.exception.KameHouseInvalidDataException;
import com.nicobrest.kamehouse.commons.exception.KameHouseServerErrorException;
import com.nicobrest.kamehouse.commons.utils.DateUtils;
import com.nicobrest.kamehouse.commons.utils.EncryptionUtils;
import com.nicobrest.kamehouse.commons.utils.HttpClientUtils;
import com.nicobrest.kamehouse.commons.utils.JsonUtils;
import com.nicobrest.kamehouse.commons.utils.PropertiesUtils;
import com.nicobrest.kamehouse.commons.utils.StringUtils;
import com.nicobrest.kamehouse.commons.utils.ThreadUtils;
import com.nicobrest.kamehouse.tennisworld.model.BookingRequest;
import com.nicobrest.kamehouse.tennisworld.model.BookingRequest.CardDetails;
import com.nicobrest.kamehouse.tennisworld.model.BookingResponse;
import com.nicobrest.kamehouse.tennisworld.model.BookingResponse.Status;
import com.nicobrest.kamehouse.tennisworld.model.SessionType;
import com.nicobrest.kamehouse.tennisworld.model.Site;
import com.nicobrest.kamehouse.tennisworld.model.scheduler.job.ScheduledBookingJob;
import org.apache.commons.io.IOUtils;
import org.apache.http.Header;
import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.message.BasicNameValuePair;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;
import java.util.UUID;
import javax.annotation.Nonnull;

/**
 * Service to execute tennis world bookings.
 *
 * @author nbrest
 */
@Service
public class BookingService {

  // URLs
  public static final String ROOT_URL = "https://bookings.tennisworld.net.au";
  private static final String INITIAL_LOGIN_URL = ROOT_URL + "/customer/mobile/login";
  private static final String SITE_LINK_HREF = "/customer/mobile/login/complete_login/";
  private static final String DASHBOARD_URL = ROOT_URL + "/customer/mobile/dashboard";
  private static final String BOOK_FACILITY_OVERLAY_AJAX_URL = ROOT_URL + "/customer/mobile/"
      + "facility/book_overlay_ajax";
  private static final String BOOK_SESSION_OVERLAY_AJAX_URL = ROOT_URL + "/customer/mobile/"
      + "session/load_session_ajax";
  private static final String FACILITY_CONFIRM_BOOKING_URL = ROOT_URL + "/customer/mobile"
      + "/facility/confirm";
  private static final String SESSION_CONFIRM_BOOKING_URL = ROOT_URL + "/customer/mobile"
      + "/session/confirm";
  // Headers
  private static final String LOCATION = "Location";
  private static final String REFERER = "Referer";
  private static final String X_REQUESTED_WITH = "X-Requested-With";
  private static final String XML_HTTP_REQUEST = "XMLHttpRequest";
  // HTML Attributes
  private static final String ATTR_DATA_ROLE = "data-role";
  private static final String ATTR_SITE_FACILITYGROUP_ID = "site_facilitygroup_id";
  private static final String ATTR_BOOKING_TIME = "booking_time";
  private static final String ATTR_EVENT_DURATION = "event_duration";
  private static final String ATTR_SESSION_ID = "session_id";
  private static final String ATTR_SESSION_DATE = "session_date";
  // HTML Ids
  private static final String ID_BOOK_NOW_OVERLAY_FACILITY = "book_now_overlayfacility";
  private static final String ID_ERROR_STACK = "error-stack";
  private static final String ID_ERROR_MESSAGE = "error-message";
  // Other constants
  public static final String INVALID_BOOKING_SERVER = "The current server is not the booking"
      + " server. Can't book a scheduled cardio session from this server.";
  public static final String SUCCESSFUL_BOOKING = "Completed the booking request successfully";
  public static final String SUCCESSFUL_BOOKING_DRY_RUN = "Completed the booking request DRY-RUN"
      + " successfully";
  public static final String BOOKING_FINISHED = "Booking to tennis world finished: ";

  private static int sleepMs = 500;

  private final Logger logger = LoggerFactory.getLogger(getClass());

  /**
   * Set the sleep ms between requests.
   */
  public static void setSleepMs(int sleepMs) {
    BookingService.sleepMs = sleepMs;
  }

  /**
   * Initiate a booking request to tennis world.
   */
  public BookingResponse book(BookingRequest bookingRequest) {
    try {
      setRequestId(bookingRequest);
      setThreadName(bookingRequest.getId());
      SessionType sessionType = getSessionType(bookingRequest);
      logger.info("Booking tennis world request: " + bookingRequest);
      switch (sessionType) {
        case CARDIO:
          return bookCardioSessionRequest(bookingRequest);
        case NTC_CLAY_COURTS:
        case NTC_OUTDOOR:
        case ROD_LAVER_OUTDOOR:
        case ROD_LAVER_SHOW_COURTS:
          return bookFacilityOverlayRequest(bookingRequest);
        case UNKNOWN:
        default:
          return buildResponse(Status.INTERNAL_ERROR,
              "Unhandled sessionType: " + sessionType.name(), bookingRequest);
      }
    } catch (KameHouseBadRequestException e) {
      return buildResponse(Status.ERROR, e.getMessage(), bookingRequest);
    }
  }

  /**
   * Execute the scheduled bookings based on the BookingScheduleConfigs set in the database.
   * This method is to be triggered by the {@link ScheduledBookingJob}.
   */
  public BookingResponse bookScheduledSessions() {
    if (!isBookingServer()) {
      logger.error(INVALID_BOOKING_SERVER);
      return buildResponse(Status.INTERNAL_ERROR, INVALID_BOOKING_SERVER, null);
    }
    BookingRequest request = getScheduledBookingRequest();
    int currentDayOfWeek = DateUtils.getCurrentDayOfWeek();
    switch (currentDayOfWeek) {
      case Calendar.SUNDAY:
        return bookScheduledSession(request, "12:00pm");
      case Calendar.MONDAY:
        return bookScheduledSession(request, "07:15pm");
      case Calendar.FRIDAY:
        return bookScheduledSession(request, "12:15pm");
      case Calendar.TUESDAY:
      case Calendar.WEDNESDAY:
      case Calendar.THURSDAY:
      case Calendar.SATURDAY:
        String message = "Today is " + DateUtils.getDayOfWeek(currentDayOfWeek)
            + ". No booking is scheduled for today";
        logger.info(message);
        return buildResponse(Status.SUCCESS, message, request);
      default:
        break;
    }
    String errorMessage = "Invalid currentDayOfWeek. Should never reach this point!";
    logger.error(errorMessage);
    throw new KameHouseServerErrorException(errorMessage);
  }

  /**
   * Book the specified scheduled cardio request at the specified time.
   */
  private BookingResponse bookScheduledSession(BookingRequest request,
                                                String time) {
    String dayOfWeek = DateUtils.getDayOfWeek(DateUtils.getCurrentDayOfWeek());
    String currentDate = DateUtils.getFormattedDate(DateUtils.YYYY_MM_DD,
        DateUtils.getCurrentDate());
    logger.info("Today is {} {}. Booking cardio for {} at {}", dayOfWeek, currentDate,
        request.getDate(), time);
    request.setTime(time);
    return book(request);
  }

  /**
   * Check if the current server is the booking sever.
   */
  private static boolean isBookingServer() {
    String bookingServer = PropertiesUtils.getProperty("booking.server");
    return PropertiesUtils.getHostname().equals(bookingServer);
  }

  /**
   * Gets the scheduled cardio username.
   */
  private String getScheduledCardioUsername() {
    String filename = PropertiesUtils.getUserHome() + "/" + PropertiesUtils
        .getProperty("scheduled.cardio.user.file");
    try {
      return EncryptionUtils.decryptKameHouseFileToString(filename);
    } catch (KameHouseInvalidDataException e) {
      logger.error("Could not retrieve the scheduled cardio username");
      return null;
    }
  }

  /**
   * Gets the scheduled cardio password.
   */
  private String getScheduledCardioPassword() {
    String filename = PropertiesUtils.getUserHome() + "/" + PropertiesUtils
        .getProperty("scheduled.cardio.pwd.file");
    try {
      return EncryptionUtils.decryptKameHouseFileToString(filename);
    } catch (KameHouseInvalidDataException e) {
      logger.error("Could not retrieve the scheduled cardio password");
      return null;
    }
  }

  /**
   * Create the cardio scheduled booking tennis world request.
   */
  private BookingRequest getScheduledBookingRequest() {
    String bookingDate = DateUtils.getFormattedDate(DateUtils.YYYY_MM_DD,
        DateUtils.getTwoWeeksFromToday());
    BookingRequest request = new BookingRequest();
    request.setDate(bookingDate);
    request.setUsername(getScheduledCardioUsername());
    request.setPassword(getScheduledCardioPassword());
    request.setDryRun(false);
    request.setDuration("45");
    request.setSessionType(SessionType.CARDIO.name());
    request.setSite(Site.MELBOURNE_PARK.name());
    return request;
  }

  /**
   * Get the sessionType enum from the request.
   */
  private static SessionType getSessionType(BookingRequest
                                                           bookingRequest) {
    try {
      return SessionType.valueOf(bookingRequest.getSessionType());
    } catch (IllegalArgumentException e) {
      throw new KameHouseBadRequestException("Invalid sessionType: "
          + bookingRequest.getSessionType());
    }
  }

  /**
   * Handle a tennis world booking for session overlay bookings. Currently those are session type:
   * <ul>
   *  <li>Book a Cardio Tennis Class</li>
   * </ul>
   * The current process to complete this type of booking is:
   * <ul>
   * <li>1.1) POST Initial login request</li>
   * <li>1.2) GET Complete login - show all sites</li>
   * <li>1.3) GET Complete login in specific site (ej. Melbourne Park)</li>
   * <li>2) GET Specific session type page</li>
   * <li>3) GET Specific session date page</li>
   * <li>4) POST Load book_overlay_ajax with the selected session_id and session_date. Check if
   * there's any errors in the response</li>
   * <li>5) GET Confirm booking url to submit the final booking request with the
   * site_session_group_id</li>
   * <li>
   *   6) POST Confirm booking for the selected session. Send the final booking request (with
   *   payment details when required)
   * </li>
   * <li>7) GET Confirm booking url. Check the final result of the booking request</li>
   * </ul>
   */
  private BookingResponse bookCardioSessionRequest(
      BookingRequest bookingRequest) {
    HttpClient httpClient = HttpClientUtils.getClient(null, null);
    try {
      // 1 -------------------------------------------------------------------------
      Document dashboard = loginToTennisWorld(httpClient, bookingRequest);
      SessionType sessionType = getSessionType(bookingRequest);
      String selectedSessionTypeId = getSessionTypeId(dashboard, sessionType.getValue());

      // 2 -------------------------------------------------------------------------
      Document sessionTypePage = getSessionTypePage(httpClient, selectedSessionTypeId);
      String selectedSessionDatePath = getSelectedSessionDatePath(sessionTypePage,
          selectedSessionTypeId, bookingRequest.getDate());

      // 3 -------------------------------------------------------------------------
      Document sessionDatePage = getSessionDatePage(httpClient, selectedSessionDatePath);
      String sessionId = getSessionId(sessionDatePage, bookingRequest);

      // 4 -------------------------------------------------------------------------
      postSessionBookOverlayAjax(httpClient, sessionId, bookingRequest.getDate());

      // 5 -------------------------------------------------------------------------
      getSessionConfirmBookingUrl(httpClient, selectedSessionDatePath);
      if (!bookingRequest.isDryRun()) {

        // 6 -------------------------------------------------------------------------
        String confirmBookingRedirectUrl = postSessionBookingRequest(httpClient,
            bookingRequest.getCardDetails());

        // 7 -------------------------------------------------------------------------
        confirmSessionBookingResult(httpClient, confirmBookingRedirectUrl);
        return buildResponse(Status.SUCCESS, SUCCESSFUL_BOOKING, bookingRequest);
      } else {
        return buildResponse(Status.SUCCESS, SUCCESSFUL_BOOKING_DRY_RUN, bookingRequest);
      }
    } catch (KameHouseBadRequestException e) {
      return buildResponse(Status.ERROR, e.getMessage(), bookingRequest);
    } catch (KameHouseServerErrorException e) {
      return buildResponse(Status.INTERNAL_ERROR, e.getMessage(), bookingRequest);
    } catch (IOException e) {
      logger.error(e.getMessage(), e);
      return buildResponse(Status.INTERNAL_ERROR, "Error executing booking request to tennis"
          + " world Message: " + e.getMessage(), bookingRequest);
    }
  }

  /**
   * Get the sessionId from the sessionDatePage.
   */
  private String getSessionId(Document sessionDatePage,
                              BookingRequest bookingRequest) {
    String sessionId = null;
    for (Element listItem : sessionDatePage.getElementsByTag("li")) {
      String sessionDate = listItem.attr(ATTR_SESSION_DATE);
      if (listItem.childrenSize() > 0) {
        String sessionTime = listItem.child(0).text();
        if (sessionTime != null && sessionTime.contains(bookingRequest.getTime())
            && sessionDate.equals(bookingRequest.getDate())) {
          sessionId = listItem.attr(ATTR_SESSION_ID);
          break;
        }
      }
    }
    logger.debug("sessionId:{}", sessionId);
    if (sessionId == null) {
      throw new KameHouseBadRequestException("Error getting the sessionId");
    }
    return sessionId;
  }

  /**
   * Step 4. Post the session book overlay ajax request and confirm that the response is not empty
   * and that it doesn't contain errors.
   */
  private void postSessionBookOverlayAjax(HttpClient httpClient, String sessionId,
                                          String sessionDate) throws IOException {
    sleep();
    List<NameValuePair> loadSessionAjaxParams = new ArrayList<>();
    loadSessionAjaxParams.add(new BasicNameValuePair(ATTR_SESSION_ID, sessionId));
    loadSessionAjaxParams.add(new BasicNameValuePair(ATTR_SESSION_DATE, sessionDate));
    HttpPost loadSessionAjaxRequestHttpPost = new HttpPost(BOOK_SESSION_OVERLAY_AJAX_URL);
    loadSessionAjaxRequestHttpPost.setEntity(new UrlEncodedFormEntity(loadSessionAjaxParams));
    loadSessionAjaxRequestHttpPost.setHeader(REFERER, ROOT_URL + "/#");
    loadSessionAjaxRequestHttpPost.setHeader(X_REQUESTED_WITH, XML_HTTP_REQUEST);
    logger.info("Step 4: POST request to: {}", BOOK_SESSION_OVERLAY_AJAX_URL);
    logRequestHeaders(loadSessionAjaxRequestHttpPost);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient,
        loadSessionAjaxRequestHttpPost);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    if (hasJsonErrorResponse(html) || hasError(Jsoup.parse(html))) {
      throw new KameHouseServerErrorException("Error posting book overlay ajax");
    }
  }

  /**
   * Step 5. Go to the confirm booking url for facility requests.
   */
  private void getSessionConfirmBookingUrl(HttpClient httpClient, String selectedSessionDatePath)
      throws IOException {
    sleep();
    String selectedSessionDateUrl = ROOT_URL + selectedSessionDatePath;
    HttpGet httpGet = HttpClientUtils.httpGet(SESSION_CONFIRM_BOOKING_URL);
    httpGet.setHeader(REFERER, selectedSessionDateUrl);
    httpGet.setHeader(X_REQUESTED_WITH, XML_HTTP_REQUEST);
    logger.info("Step 5: GET request to: {}", SESSION_CONFIRM_BOOKING_URL);
    logRequestHeaders(httpGet);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, httpGet);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    if (hasError(Jsoup.parse(html))) {
      throw new KameHouseServerErrorException("Error getting the confirm booking page");
    }
  }

  /**
   * Step 6. Post the session booking request (finally!) and check if there's any errors.
   * I expect a 302 redirect response, so if that's not the case, mark the request as error.
   */
  private String postSessionBookingRequest(HttpClient httpClient, CardDetails cardDetails)
      throws IOException {
    sleep();
    List<NameValuePair> confirmBookingParams = new ArrayList<>();
    populateCardDetails(confirmBookingParams, cardDetails);
    confirmBookingParams.add(new BasicNameValuePair("submit", "Confirm and pay"));
    HttpPost confirmBookingHttpPost = new HttpPost(SESSION_CONFIRM_BOOKING_URL);
    confirmBookingHttpPost.setEntity(new UrlEncodedFormEntity(confirmBookingParams));
    confirmBookingHttpPost.setHeader(REFERER, SESSION_CONFIRM_BOOKING_URL);
    confirmBookingHttpPost.setHeader(X_REQUESTED_WITH, XML_HTTP_REQUEST);
    logger.info("Step 6: POST request to: {}", SESSION_CONFIRM_BOOKING_URL);
    logRequestHeaders(confirmBookingHttpPost);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, confirmBookingHttpPost);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    Document postBookingResponsePage = Jsoup.parse(html);
    if (hasError(postBookingResponsePage)) {
      throw new KameHouseServerErrorException("Error posting booking request: "
          + Arrays.toString(getErrorStackMessages(postBookingResponsePage).toArray()));
    }
    if (HttpClientUtils.getStatusCode(httpResponse) != HttpStatus.FOUND.value()) {
      throw new KameHouseServerErrorException("Error posting booking request. Expected a "
          + "redirect response");
    }
    return HttpClientUtils.getHeader(httpResponse, LOCATION);
  }

  /**
   * Step 7. Confirm the session booking final result.
   */
  private void confirmSessionBookingResult(HttpClient httpClient, String confirmBookingRedirectUrl)
      throws IOException {
    sleep();
    HttpGet httpGet = HttpClientUtils.httpGet(confirmBookingRedirectUrl);
    httpGet.setHeader(REFERER, SESSION_CONFIRM_BOOKING_URL);
    httpGet.setHeader(X_REQUESTED_WITH, XML_HTTP_REQUEST);
    logger.info("Step 7: GET request to: {}", confirmBookingRedirectUrl);
    logRequestHeaders(httpGet);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, httpGet);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    Document confirmFinalBookingPage = Jsoup.parse(html);
    if (hasError(confirmFinalBookingPage)) {
      throw new KameHouseServerErrorException("Error confirming booking result: "
          + Arrays.toString(getErrorStackMessages(confirmFinalBookingPage).toArray()));
    }
  }

  /**
   * Handle a tennis world booking for facility overlay bookings. Currently those are session types:
   * <ul>
   *  <li>National Tennis Outdoor</li>
   *  <li>NTC Clay Courts</li>
   *  <li>Rod Laver Arena Outdoor</li>
   *  <li>Rod Laver Arena Show Courts</li>
   * </ul>
   * The current process to complete a facility overlay booking is:
   * <ul>
   * <li>1.1) POST Initial login request</li>
   * <li>1.2) GET Complete login - show all sites</li>
   * <li>1.3) GET Complete login in specific site (ej. Melbourne Park)</li>
   * <li>2) GET Specific session type page</li>
   * <li>3) GET Specific session date page</li>
   * <li>4) GET Specific session page (session type, date and time)</li>
   * <li>5) POST Load book_overlay_ajax. Check if there's any errors in the response</li>
   * <li>6) GET Confirm booking url to submit the final booking request</li>
   * <li>
   *   7) POST Confirm booking. Send the final booking request (with payment details when required)
   * </li>
   * <li>8) GET Confirm booking url. Check the final result of the booking request</li>
   * </ul>
   */
  private BookingResponse bookFacilityOverlayRequest(
      BookingRequest bookingRequest) {
    HttpClient httpClient = HttpClientUtils.getClient(null, null);
    try {
      // 1 -------------------------------------------------------------------------
      Document dashboard = loginToTennisWorld(httpClient, bookingRequest);
      SessionType sessionType = getSessionType(bookingRequest);
      String selectedSessionTypeId = getSessionTypeId(dashboard, sessionType.getValue());

      // 2 -------------------------------------------------------------------------
      Document sessionTypePage = getSessionTypePage(httpClient, selectedSessionTypeId);
      String selectedSessionDatePath = getSelectedSessionDatePath(sessionTypePage,
          selectedSessionTypeId, bookingRequest.getDate());

      // 3 -------------------------------------------------------------------------
      Document sessionDatePage = getSessionDatePage(httpClient, selectedSessionDatePath);
      String selectedSessionPath = getSelectedSessionPath(sessionDatePage,
          bookingRequest.getTime());

      // 4 -------------------------------------------------------------------------
      Document sessionPage = getSessionPage(httpClient, selectedSessionPath);
      String siteFacilityGroupId = getSiteFacilityGroupId(sessionPage);
      String bookingTime = getBookingTime(sessionPage);

      // 5 -------------------------------------------------------------------------
      postFacilityBookOverlayAjax(httpClient, selectedSessionDatePath, siteFacilityGroupId,
          bookingTime, bookingRequest.getDuration());

      // 6 -------------------------------------------------------------------------
      getFacilityConfirmBookingUrl(httpClient, selectedSessionDatePath);
      if (!bookingRequest.isDryRun()) {

        // 7 -------------------------------------------------------------------------
        String confirmBookingRedirectUrl = postFacilityBookingRequest(httpClient,
            bookingRequest.getCardDetails());

        // 8 -------------------------------------------------------------------------
        confirmFacilityBookingResult(httpClient, confirmBookingRedirectUrl);
        return buildResponse(Status.SUCCESS, SUCCESSFUL_BOOKING, bookingRequest);
      } else {
        return buildResponse(Status.SUCCESS, SUCCESSFUL_BOOKING_DRY_RUN, bookingRequest);
      }
    } catch (KameHouseBadRequestException e) {
      return buildResponse(Status.ERROR, e.getMessage(), bookingRequest);
    } catch (KameHouseServerErrorException e) {
      return buildResponse(Status.INTERNAL_ERROR, e.getMessage(), bookingRequest);
    } catch (IOException e) {
      logger.error(e.getMessage(), e);
      return buildResponse(Status.INTERNAL_ERROR, "Error executing booking request to tennis"
          + " world Message: " + e.getMessage(), bookingRequest);
    }
  }

  /**
   * Steps 1.1, 1.2 and 1.3.
   * Attempts to login to tennis world using the specified site and credentials in the
   * BookingRequest and returns the dashboard page if the login is successful.
   */
  private Document loginToTennisWorld(HttpClient httpClient,
                                      BookingRequest bookingRequest)
      throws IOException {
    // 1.1 -------------------------------------------------------------------------
    List<NameValuePair> params = new ArrayList<>();
    params.add(new BasicNameValuePair("username", bookingRequest.getUsername()));
    params.add(new BasicNameValuePair("password", bookingRequest.getPassword()));

    HttpPost initialLoginPostRequest = new HttpPost(INITIAL_LOGIN_URL);
    initialLoginPostRequest.setEntity(new UrlEncodedFormEntity(params));
    logger.info("Step 1.1: POST request to: {}", INITIAL_LOGIN_URL);
    HttpResponse initialLoginPostResponse =
        HttpClientUtils.execRequest(httpClient, initialLoginPostRequest);
    logHttpResponseCode(initialLoginPostResponse);
    String initialLoginHtml =
        IOUtils.toString(HttpClientUtils.getInputStream(initialLoginPostResponse));
    logger.debug(initialLoginHtml);
    if (hasLoginError(initialLoginHtml)
        || HttpClientUtils.getStatusCode(initialLoginPostResponse) != HttpStatus.FOUND.value()) {
      throw new KameHouseBadRequestException("Invalid login to tennis world");
    }

    // 1.2 -------------------------------------------------------------------------
    sleep();
    String completeLoginUrl = HttpClientUtils.getHeader(initialLoginPostResponse, LOCATION);
    HttpGet completeLoginAllSitesGetRequest = HttpClientUtils.httpGet(completeLoginUrl);
    logger.info("Step 1.2: GET request to: {}", completeLoginUrl);
    logRequestHeaders(completeLoginAllSitesGetRequest);
    HttpResponse completeLoginAllSitesGetResponse =
        HttpClientUtils.execRequest(httpClient, completeLoginAllSitesGetRequest);
    logHttpResponseCode(completeLoginAllSitesGetResponse);
    String completeLoginAllSitesResponseHtml = IOUtils.toString(
            HttpClientUtils.getInputStream(completeLoginAllSitesGetResponse));
    logger.debug(completeLoginAllSitesResponseHtml);
    Document completeLoginAllSitesResponsePage =
        Jsoup.parse(completeLoginAllSitesResponseHtml);
    Elements tennisWorldSiteLinks = completeLoginAllSitesResponsePage
        .getElementsByAttributeValueMatching("href", SITE_LINK_HREF);
    String selectedSiteId = null;
    for (Element tennisWorldSiteLink : tennisWorldSiteLinks) {
      String siteName = tennisWorldSiteLink.getElementsByTag("p").text();
      String siteId = tennisWorldSiteLink.attr("href").substring(SITE_LINK_HREF.length());
      logger.debug("siteName:{}; siteId:{}", siteName, siteId);
      Site site = getSite(bookingRequest);
      if (siteName != null && siteName.equalsIgnoreCase(site.getValue())) {
        selectedSiteId = siteId;
      }
    }
    if (selectedSiteId == null || hasError(completeLoginAllSitesResponsePage)) {
      throw new KameHouseBadRequestException("Unable to determine the site id for "
          + bookingRequest.getSite());
    }

    // 1.3 -------------------------------------------------------------------------
    sleep();
    String completeLoginSelectedSiteUrl = completeLoginUrl + "/" + selectedSiteId;
    HttpGet completeLoginSelectedSiteGetRequest =
        HttpClientUtils.httpGet(completeLoginSelectedSiteUrl);
    logger.info("Step 1.3: GET request to: {}", completeLoginSelectedSiteUrl);
    logRequestHeaders(completeLoginSelectedSiteGetRequest);
    HttpResponse completeLoginSelectedSiteResponse =
        HttpClientUtils.execRequest(httpClient, completeLoginSelectedSiteGetRequest);
    logHttpResponseCode(completeLoginSelectedSiteResponse);
    String completeLoginSelectedSiteResponseHtml = IOUtils.toString(
            HttpClientUtils.getInputStream(completeLoginSelectedSiteResponse));
    logger.debug(completeLoginSelectedSiteResponseHtml);
    Document completeLoginSelectedSiteResponsePage =
        Jsoup.parse(completeLoginSelectedSiteResponseHtml);
    if (hasError(completeLoginSelectedSiteResponsePage)) {
      throw new KameHouseServerErrorException("Unable to complete login to siteId "
          + selectedSiteId);
    }
    return completeLoginSelectedSiteResponsePage;
  }

  /**
   * Get the tennis world site location.
   */
  private static Site getSite(BookingRequest bookingRequest) {
    try {
      return Site.valueOf(bookingRequest.getSite());
    } catch (IllegalArgumentException e) {
      throw new KameHouseBadRequestException("Invalid site: "
          + bookingRequest.getSite());
    }
  }

  /**
   * Get the session type id from the specified session type.
   */
  private String getSessionTypeId(Document dashboard, String sessionType) {
    String selectedSessionTypeId = null;
    Elements sessionTypes = dashboard.getElementsByAttributeValue(ATTR_DATA_ROLE, "page");
    for (Element sessionTypeElement : sessionTypes) {
      String sessionTypeName = sessionTypeElement.getElementsByTag("h1").text();
      String sessionTypeId = sessionTypeElement.attr("id");
      logger.debug("sessionTypeName:{}; sessionTypeId:{}", sessionTypeName, sessionTypeId);
      if (sessionTypeName != null
          && sessionTypeName.equalsIgnoreCase(sessionType)) {
        selectedSessionTypeId = sessionTypeId;
      }
    }
    logger.debug("selectedSessionTypeId:{}", selectedSessionTypeId);
    if (selectedSessionTypeId == null) {
      throw new KameHouseBadRequestException("Unable to get the selectedSessionTypeId");
    }
    return selectedSessionTypeId;
  }

  /**
   * Step 2. Get the session type page.
   */
  private Document getSessionTypePage(HttpClient httpClient, String selectedSessionTypeId)
      throws IOException {
    String selectedSessionTypeUrl = DASHBOARD_URL + "#" +  selectedSessionTypeId;
    HttpGet httpGet = HttpClientUtils.httpGet(selectedSessionTypeUrl);
    logger.info("Step 2: GET request to: {}", selectedSessionTypeUrl);
    logRequestHeaders(httpGet);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, httpGet);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    Document sessionTypePage = Jsoup.parse(html);
    if (hasError(sessionTypePage)) {
      throw new KameHouseServerErrorException("Error getting session type page");
    }
    return sessionTypePage;
  }

  /**
   * Get the selected session date path from the session type page returned from tennis world.
   */
  private String getSelectedSessionDatePath(Document sessionTypePage, String selectedSessionTypeId,
                                            String date) {
    Elements sessionsForTheSelectedSessionType =
        sessionTypePage.getElementById(selectedSessionTypeId).getElementsByTag("a");
    String selectedSessionDatePath = null;
    for (Element sessionForTheSelectedSessionType : sessionsForTheSelectedSessionType) {
      String href = sessionForTheSelectedSessionType.attr("href");
      logger.debug("SessionDatePath:{}", href);
      if (href != null && href.contains(date)) {
        selectedSessionDatePath = href;
      }
    }
    logger.debug("selectedSessionDatePath:{}", selectedSessionDatePath);
    if (selectedSessionDatePath == null) {
      throw new KameHouseBadRequestException("Error getting the selectedSessionDatePath");
    }
    return selectedSessionDatePath;
  }

  /**
   * Step 3. Get the selected session date page.
   */
  private Document getSessionDatePage(HttpClient httpClient, String selectedSessionDatePath)
      throws IOException {
    sleep();
    String selectedSessionDateUrl = ROOT_URL + selectedSessionDatePath;
    HttpGet httpGet = HttpClientUtils.httpGet(selectedSessionDateUrl);
    logger.info("Step 3: GET request to: {}", selectedSessionDateUrl);
    logRequestHeaders(httpGet);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, httpGet);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    Document sessionDatePage = Jsoup.parse(html);
    if (hasError(sessionDatePage)) {
      throw new KameHouseServerErrorException("Error detected getting the session date page");
    }
    return sessionDatePage;
  }

  /**
   * Get the selected session path.
   */
  private String getSelectedSessionPath(Document sessionDatePage, String bookingTime) {
    Elements listView = sessionDatePage.getElementsByAttributeValue(ATTR_DATA_ROLE, "listview");
    String selectedSessionPath = null;
    if (listView != null) {
      Elements sessionsForTheSelectedSessionDate = listView.first().getElementsByTag("a");
      for (Element sessionForTheSelectedSessionDate : sessionsForTheSelectedSessionDate) {
        String sessionHref = sessionForTheSelectedSessionDate.attr("href");
        String sessionTime = sessionForTheSelectedSessionDate.text();
        logger.debug("SessionPath:time:{}; href:{}", sessionTime, sessionHref);
        if (sessionTime != null && sessionTime.equalsIgnoreCase(bookingTime)) {
          selectedSessionPath = sessionHref;
        }
      }
    }
    logger.debug("selectedSessionPath:{}", selectedSessionPath);
    if (selectedSessionPath == null) {
      throw new KameHouseBadRequestException("Unable to get the selectedSessionPath");
    }
    return selectedSessionPath;
  }

  /**
   * Step 4. Get the selected session page (session type, date and time).
   */
  private Document getSessionPage(HttpClient httpClient, String selectedSessionPath)
      throws IOException {
    sleep();
    String selectedSessionUrl = ROOT_URL + selectedSessionPath;
    HttpGet httpGet = HttpClientUtils.httpGet(selectedSessionUrl);
    logger.info("Step 4: GET request to: {}", selectedSessionUrl);
    logRequestHeaders(httpGet);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, httpGet);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    Document sessionPage = Jsoup.parse(html);
    if (hasError(sessionPage)) {
      throw new KameHouseServerErrorException("Unable to get the session page");
    }
    return sessionPage;
  }

  /**
   * Get the site facility group id from the session page.
   */
  private String getSiteFacilityGroupId(Document sessionPage) {
    String siteFacilityGroupId = sessionPage.getElementById(ID_BOOK_NOW_OVERLAY_FACILITY)
        .attr(ATTR_SITE_FACILITYGROUP_ID);
    logger.debug("siteFacilityGroupId:{}", siteFacilityGroupId);
    if (siteFacilityGroupId == null) {
      throw new KameHouseBadRequestException("Unable to get the siteFacilityGroupId");
    }
    return siteFacilityGroupId;
  }

  /**
   * Get the booking time from the session page.
   */
  private String getBookingTime(Document sessionPage) {
    String bookingTime = sessionPage.getElementById(ID_BOOK_NOW_OVERLAY_FACILITY)
        .attr(ATTR_BOOKING_TIME);
    logger.debug("bookingTime:{}", bookingTime);
    if (bookingTime == null) {
      throw new KameHouseBadRequestException("Unable to get the bookingTime");
    }
    return bookingTime;
  }

  /**
   * Step 5. Post the book overlay ajax request and confirm that the response is not empty and
   * that it doesn't contain errors.
   */
  private void postFacilityBookOverlayAjax(HttpClient httpClient, String selectedSessionDatePath,
                                          String siteFacilityGroupId, String bookingTime,
                                          String bookingDuration) throws IOException {
    sleep();
    List<NameValuePair> loadSessionAjaxParams = new ArrayList<>();
    loadSessionAjaxParams.add(new BasicNameValuePair(ATTR_SITE_FACILITYGROUP_ID,
        siteFacilityGroupId));
    loadSessionAjaxParams.add(new BasicNameValuePair(ATTR_BOOKING_TIME, bookingTime));
    loadSessionAjaxParams.add(new BasicNameValuePair(ATTR_EVENT_DURATION, bookingDuration));
    HttpPost loadSessionAjaxRequestHttpPost = new HttpPost(BOOK_FACILITY_OVERLAY_AJAX_URL);
    loadSessionAjaxRequestHttpPost.setEntity(new UrlEncodedFormEntity(loadSessionAjaxParams));
    loadSessionAjaxRequestHttpPost.setHeader(REFERER, ROOT_URL + selectedSessionDatePath);
    loadSessionAjaxRequestHttpPost.setHeader(X_REQUESTED_WITH, XML_HTTP_REQUEST);
    logger.info("Step 5: POST request to: {}", BOOK_FACILITY_OVERLAY_AJAX_URL);
    logRequestHeaders(loadSessionAjaxRequestHttpPost);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient,
        loadSessionAjaxRequestHttpPost);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    if (hasJsonErrorResponse(html) || hasError(Jsoup.parse(html))) {
      throw new KameHouseServerErrorException("Error posting book overlay ajax");
    }
  }

  /**
   * Step 6. Go to the confirm booking url for facility requests.
   */
  private void getFacilityConfirmBookingUrl(HttpClient httpClient, String selectedSessionDatePath)
      throws IOException {
    sleep();
    String selectedSessionDateUrl = ROOT_URL + selectedSessionDatePath;
    HttpGet httpGet = HttpClientUtils.httpGet(FACILITY_CONFIRM_BOOKING_URL);
    httpGet.setHeader(REFERER, selectedSessionDateUrl);
    httpGet.setHeader(X_REQUESTED_WITH, XML_HTTP_REQUEST);
    logger.info("Step 6: GET request to: {}", FACILITY_CONFIRM_BOOKING_URL);
    logRequestHeaders(httpGet);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, httpGet);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    if (hasError(Jsoup.parse(html))) {
      throw new KameHouseServerErrorException("Error getting the confirm booking page");
    }
  }

  /**
   * Step 7. Post the booking request (finally!) and check if there's any errors.
   * I expect a 302 redirect response, so if that's not the case, mark the request as error.
   */
  private String postFacilityBookingRequest(HttpClient httpClient, CardDetails cardDetails)
      throws IOException {
    sleep();
    List<NameValuePair> confirmBookingParams = new ArrayList<>();
    populateCardDetails(confirmBookingParams, cardDetails);
    confirmBookingParams.add(new BasicNameValuePair("submit", "Confirm and pay"));
    HttpPost confirmBookingHttpPost = new HttpPost(FACILITY_CONFIRM_BOOKING_URL);
    confirmBookingHttpPost.setEntity(new UrlEncodedFormEntity(confirmBookingParams));
    confirmBookingHttpPost.setHeader(REFERER, FACILITY_CONFIRM_BOOKING_URL);
    confirmBookingHttpPost.setHeader(X_REQUESTED_WITH, XML_HTTP_REQUEST);
    logger.info("Step 7: POST request to: {}", FACILITY_CONFIRM_BOOKING_URL);
    logRequestHeaders(confirmBookingHttpPost);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, confirmBookingHttpPost);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    Document postBookingResponsePage = Jsoup.parse(html);
    if (hasError(postBookingResponsePage)) {
      throw new KameHouseServerErrorException("Error posting booking request: "
          + Arrays.toString(getErrorStackMessages(postBookingResponsePage).toArray()));
    }
    if (HttpClientUtils.getStatusCode(httpResponse) != HttpStatus.FOUND.value()) {
      throw new KameHouseServerErrorException("Error posting booking request. Expected a "
          + "redirect response");
    }
    return HttpClientUtils.getHeader(httpResponse, LOCATION);
  }

  /**
   * Set the payment details to complete the booking request.
   */
  private static void populateCardDetails(List<NameValuePair> params, CardDetails cardDetails) {
    if (cardDetails != null) {
      params.add(new BasicNameValuePair("name_on_card", cardDetails.getName()));
      params.add(new BasicNameValuePair("credit_card_number", cardDetails.getNumber()));
      params.add(new BasicNameValuePair("expiry_month", cardDetails.getExpiryMonth()));
      params.add(new BasicNameValuePair("expiry_year", cardDetails.getExpiryYear()));
      params.add(new BasicNameValuePair("cvv_number", cardDetails.getCvv()));
    }
  }

  /**
   * Step 8. Confirm the facility booking final result.
   */
  private void confirmFacilityBookingResult(HttpClient httpClient, String confirmBookingRedirectUrl)
      throws IOException {
    sleep();
    HttpGet httpGet = HttpClientUtils.httpGet(confirmBookingRedirectUrl);
    httpGet.setHeader(REFERER, FACILITY_CONFIRM_BOOKING_URL);
    httpGet.setHeader(X_REQUESTED_WITH, XML_HTTP_REQUEST);
    logger.info("Step 8: GET request to: {}", confirmBookingRedirectUrl);
    logRequestHeaders(httpGet);
    HttpResponse httpResponse = HttpClientUtils.execRequest(httpClient, httpGet);
    logHttpResponseCode(httpResponse);
    String html = IOUtils.toString(HttpClientUtils.getInputStream(httpResponse));
    logger.debug(html);
    Document confirmFinalBookingPage = Jsoup.parse(html);
    if (hasError(confirmFinalBookingPage)) {
      throw new KameHouseServerErrorException("Error confirming booking result: "
            + Arrays.toString(getErrorStackMessages(confirmFinalBookingPage).toArray()));
    }
  }

  /**
   * Build a tennis world response with the specified status and message.
   */
  private BookingResponse buildResponse(Status status, String message,
                                        BookingRequest request) {
    BookingResponse bookingResponse = new BookingResponse();
    bookingResponse.setStatus(status);
    bookingResponse.setMessage(message);
    if (request != null) {
      bookingResponse.setId(request.getId());
      bookingResponse.setUsername(request.getUsername());
      bookingResponse.setDate(request.getDate());
      bookingResponse.setTime(request.getTime());
      bookingResponse.setSessionType(request.getSessionType());
      bookingResponse.setSite(request.getSite());
    }
    if (bookingResponse.getStatus() != Status.SUCCESS) {
      logger.error(BOOKING_FINISHED + bookingResponse);
    } else {
      logger.info(BOOKING_FINISHED + bookingResponse);
    }
    return bookingResponse;
  }

  /**
   * Log request headers.
   */
  private void logRequestHeaders(HttpRequest httpRequest) {
    logger.debug("Request headers:");
    if (httpRequest.getAllHeaders() == null || httpRequest.getAllHeaders().length == 0) {
      logger.debug("No request headers set");
    }
    for (Header header : httpRequest.getAllHeaders()) {
      logger.debug("{} : {}", header.getName(), header.getValue());
    }
  }

  /**
   * Log the response code received from tennis world.
   */
  private void logHttpResponseCode(HttpResponse httpResponse) {
    logger.info("Response code: {}", HttpClientUtils.getStatusLine(httpResponse));
  }

  /**
   * Returns the list of errors in the error stack or an empty list if no errors.
   */
  private List<String> getErrorStackMessages(Document page) {
    List<String> errors = new ArrayList<>();
    if (page != null
        && page.getElementById(ID_ERROR_STACK) != null) {
      Elements errorMessages = page.getElementById(ID_ERROR_STACK).getElementsByTag("p");
      if (errorMessages != null && !errorMessages.isEmpty()) {
        addErrorMessagesToList(errorMessages, errors);
      }
    }
    return errors;
  }

  /**
   * Iterate over error messages and add them to the specified list of errors.
   */
  private void addErrorMessagesToList(Elements errorMessages, List<String> errors) {
    for (Element errorMessage : errorMessages) {
      if (ID_ERROR_MESSAGE.equals(errorMessage.id())
          && !StringUtils.isEmpty(errorMessage.text())) {
        if (logger.isErrorEnabled()) {
          logger.error(errorMessage.text());
        }
        errors.add(errorMessage.text());
      }
    }
  }

  /**
   * Checks if the specified html string contains error messages from tennis world.
   * Expects a page to be always set, so if it's null, return true.
   */
  private boolean hasError(Document page) {
    if (page == null) {
      return true;
    }
    List<String> errors = getErrorStackMessages(page);
    if (!errors.isEmpty()) {
      logger.error("The following errors were detected in the current step:" + errors.toString());
    }
    return !errors.isEmpty();
  }

  /**
   * Checks if the specified html has a login error message. If the html is empty return true, as
   * I expect content when calling this method.
   */
  private static boolean hasLoginError(String html) {
    if (StringUtils.isEmpty(html)) {
      return true;
    } else {
      if (html.contains("An error has occured") || html.contains("An error has occurred")) {
        return html.contains("username or password is invalid");
      }
    }
    return false;
  }

  /**
   * Checks if the response is a json object with an error:true property. I'm expecting content
   * when calling this method, so return true if the input html is empty.
   */
  private static boolean hasJsonErrorResponse(String html) {
    if (StringUtils.isEmpty(html)) {
      return true;
    }
    return JsonUtils.getBoolean(JsonUtils.toJson(html), "error");
  }

  /**
   * Sleep for the specified ms by sleepMs.
   */
  private static void sleep() {
    try {
      Thread.sleep(sleepMs);
    } catch (InterruptedException e) {
      Thread.currentThread().interrupt();
    }
  }

  /**
   * Generates a random request id.
   */
  private static String generateRequestId() {
    StringBuilder sb = new StringBuilder();
    sb.append(System.currentTimeMillis());
    sb.append("-");
    sb.append(UUID.randomUUID().toString());
    return sb.toString();
  }

  /**
   * Set a new request id on a tennisworld booking request.
   */
  private static void setRequestId(BookingRequest request) {
    request.setId(generateRequestId());
  }

  /**
   * Sets the current processing thread id from the tennisworld request id.
   */
  private static void setThreadName(@Nonnull String requestId) {
    StringBuilder sb = new StringBuilder();
    sb.append("tw-book-");
    sb.append(requestId.substring(14, 22));
    sb.append("-");
    sb.append(requestId.substring(requestId.length() - 12, requestId.length()));
    ThreadUtils.setCurrentThreadName(sb.toString());
  }
}
