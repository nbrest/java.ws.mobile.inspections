package com.nicobrest.kamehouse.tennisworld.model.dto;

import com.nicobrest.kamehouse.commons.model.dto.KameHouseDto;
import com.nicobrest.kamehouse.commons.utils.DateUtils;
import com.nicobrest.kamehouse.commons.utils.JsonUtils;
import com.nicobrest.kamehouse.tennisworld.model.BookingScheduleConfig;
import com.nicobrest.kamehouse.tennisworld.model.SessionType;
import com.nicobrest.kamehouse.tennisworld.model.Site;
import com.nicobrest.kamehouse.tennisworld.model.TennisWorldUser;
import edu.umd.cs.findbugs.annotations.SuppressFBWarnings;
import java.io.Serializable;
import java.util.Date;
import java.util.Objects;
import org.apache.commons.lang3.BooleanUtils;

/**
 * BookingScheduleConfig DTO.
 *
 * @author nbrest
 */
public class BookingScheduleConfigDto implements KameHouseDto<BookingScheduleConfig>, Serializable {

  private static final long serialVersionUID = 159367676076449689L;

  private Long id;
  private TennisWorldUser tennisWorldUser;
  private SessionType sessionType;
  private Site site;
  private DateUtils.Day day;
  private String time;
  private Date bookingDate;
  private Integer bookAheadDays;
  private Boolean enabled;
  private String duration;

  @Override
  public BookingScheduleConfig buildEntity() {
    BookingScheduleConfig entity = new BookingScheduleConfig();
    entity.setId(getId());
    entity.setTennisWorldUser(getTennisWorldUser());
    entity.setSessionType(getSessionType());
    entity.setSite(getSite());
    entity.setDay(getDay());
    entity.setTime(getTime());
    entity.setBookingDate(getBookingDate());
    entity.setBookAheadDays(getBookAheadDays());
    entity.setEnabled(BooleanUtils.isTrue(getEnabled()));
    entity.setDuration(getDuration());
    return entity;
  }

  @Override
  public Long getId() {
    return id;
  }

  @Override
  public void setId(Long id) {
    this.id = id;
  }

  @SuppressFBWarnings(value = "EI_EXPOSE_REP")
  public TennisWorldUser getTennisWorldUser() {
    return tennisWorldUser;
  }

  @SuppressFBWarnings(value = "EI_EXPOSE_REP2")
  public void setTennisWorldUser(TennisWorldUser tennisWorldUser) {
    this.tennisWorldUser = tennisWorldUser;
  }

  public SessionType getSessionType() {
    return sessionType;
  }

  public void setSessionType(SessionType sessionType) {
    this.sessionType = sessionType;
  }

  public Site getSite() {
    return site;
  }

  public void setSite(Site site) {
    this.site = site;
  }

  public DateUtils.Day getDay() {
    return day;
  }

  public void setDay(DateUtils.Day day) {
    this.day = day;
  }

  public String getTime() {
    return time;
  }

  public void setTime(String time) {
    this.time = time;
  }

  /**
   * Get booking date.
   */
  public Date getBookingDate() {
    if (bookingDate != null) {
      return (Date) bookingDate.clone();
    } else {
      return null;
    }
  }

  /**
   * Set booking date.
   */
  public void setBookingDate(Date bookingDate) {
    if (bookingDate != null) {
      this.bookingDate = (Date) bookingDate.clone();
    }
  }

  public Integer getBookAheadDays() {
    return bookAheadDays;
  }

  public void setBookAheadDays(Integer bookAheadDays) {
    this.bookAheadDays = bookAheadDays;
  }

  public Boolean getEnabled() {
    return enabled;
  }

  public void setEnabled(Boolean enabled) {
    this.enabled = enabled;
  }

  public String getDuration() {
    return duration;
  }

  public void setDuration(String duration) {
    this.duration = duration;
  }

  @Override
  public boolean equals(Object other) {
    if (this == other) {
      return true;
    }
    if (other == null || getClass() != other.getClass()) {
      return false;
    }
    BookingScheduleConfigDto that = (BookingScheduleConfigDto) other;
    return Objects.equals(id, that.id)
        && Objects.equals(tennisWorldUser, that.tennisWorldUser)
        && sessionType == that.sessionType
        && site == that.site
        && day == that.day
        && Objects.equals(time, that.time)
        && Objects.equals(bookingDate, that.bookingDate)
        && Objects.equals(bookAheadDays, that.bookAheadDays);
  }

  @Override
  public int hashCode() {
    return Objects.hash(
        id, tennisWorldUser, sessionType, site, day, time, bookingDate, bookAheadDays);
  }

  @Override
  public String toString() {
    return JsonUtils.toJsonString(this, super.toString());
  }
}
