package com.nicobrest.kamehouse.admin.model.systemcommand;

import com.nicobrest.kamehouse.commons.model.systemcommand.SystemCommand;
import java.util.Arrays;

/**
 * System command to cancel a scheduled shutdown of the server.
 *
 * @author nbrest
 */
public class ShutdownCancelSystemCommand extends SystemCommand {

  /** Sets the command line for each operation system required for this SystemCommand. */
  public ShutdownCancelSystemCommand() {
    linuxCommand.addAll(Arrays.asList("/bin/bash", "-c", "sudo /sbin/shutdown -c"));
    windowsCommand.addAll(Arrays.asList("cmd.exe", "/c", "start", "shutdown", "/a"));
    setOutputCommand();
  }
}
