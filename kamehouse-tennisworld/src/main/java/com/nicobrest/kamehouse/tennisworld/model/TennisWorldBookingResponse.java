package com.nicobrest.kamehouse.tennisworld.model;

import com.nicobrest.kamehouse.commons.utils.JsonUtils;

import java.io.Serializable;
import java.util.Objects;

/**
 * Response containing the final status for a tennis world booking request.
 *
 * @author nbrest
 */
public class TennisWorldBookingResponse implements Serializable {

  private static final long serialVersionUID = 1L;

  private Status status;
  private String message;
  private String username;
  private String date;
  private String time;
  private String sessionType;
  private String site;

  public Status getStatus() {
    return status;
  }

  public void setStatus(Status status) {
    this.status = status;
  }

  public String getMessage() {
    return message;
  }

  public void setMessage(String message) {
    this.message = message;
  }

  public String getUsername() {
    return username;
  }

  public void setUsername(String username) {
    this.username = username;
  }

  public String getDate() {
    return date;
  }

  public void setDate(String date) {
    this.date = date;
  }

  public String getTime() {
    return time;
  }

  public void setTime(String time) {
    this.time = time;
  }

  public String getSessionType() {
    return sessionType;
  }

  public void setSessionType(String sessionType) {
    this.sessionType = sessionType;
  }

  public String getSite() {
    return site;
  }

  public void setSite(String site) {
    this.site = site;
  }

  @Override
  public boolean equals(Object other) {
    if (this == other) {
      return true;
    }
    if (other == null || getClass() != other.getClass()) {
      return false;
    }
    TennisWorldBookingResponse that = (TennisWorldBookingResponse) other;
    return status == that.status
        && Objects.equals(message, that.message)
        && Objects.equals(username, that.username)
        && Objects.equals(date, that.date)
        && Objects.equals(time, that.time)
        && Objects.equals(sessionType, that.sessionType)
        && Objects.equals(site, that.site);
  }

  @Override
  public int hashCode() {
    return Objects.hash(status, message, username, date, time, sessionType, site);
  }

  @Override
  public String toString() {
    return JsonUtils.toJsonString(this, super.toString());
  }

  /**
   * Final status of the tennis world booking request.
   */
  public enum Status {
    SUCCESS,
    ERROR,
    INTERNAL_ERROR
  }
}
