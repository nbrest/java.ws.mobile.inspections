package com.nicobrest.kamehouse.testmodule.model.scheduler.job;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Sample job to be scheduled.
 *
 * @author nbrest
 *
 */
public class SampleJob implements Job {

  protected final Logger logger = LoggerFactory.getLogger(getClass());

  /**
   * Execute the sample job.
   */
  @Override
  public void execute(JobExecutionContext context) {
    logger.info("Job {} fired @ {}", context.getJobDetail().getKey().getName(),
        context.getFireTime());
    logger.info("Do something here or auto-wire a service and call it to do something");
    logger.info("Next job scheduled @ {}", context.getNextFireTime());
  }
}