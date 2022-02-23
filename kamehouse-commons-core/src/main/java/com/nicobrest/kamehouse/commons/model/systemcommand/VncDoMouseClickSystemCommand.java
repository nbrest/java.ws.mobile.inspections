package com.nicobrest.kamehouse.commons.model.systemcommand;

import com.nicobrest.kamehouse.commons.utils.PropertiesUtils;
import java.util.Arrays;

/**
 * System command to click the mouse in the server screen using VncDo. The coordinates start from
 * "0" "0" on the top left of the screen.
 *
 * @author nbrest
 */
public class VncDoMouseClickSystemCommand extends VncDoSystemCommand {

  /** Sets the command line for each operation system required for this SystemCommand. */
  public VncDoMouseClickSystemCommand(
      String numberOfClicks, String horizontalPosition, String verticalPosition) {
    executeOnDockerHost = true;
    String hostname = PropertiesUtils.getHostname();
    String vncServerPassword = getVncServerPassword();
    addBashPrefix();
    String vncDoCommandLinux =
        "/usr/local/bin/vncdo --server "
            + hostname
            + " --password "
            + vncServerPassword
            + " move "
            + horizontalPosition
            + " "
            + verticalPosition
            + " click "
            + numberOfClicks;
    linuxCommand.add(vncDoCommandLinux);
    windowsCommand.addAll(
        Arrays.asList(
            "cmd.exe",
            "/c",
            "vncdo",
            "--server",
            hostname,
            "--password",
            vncServerPassword,
            "move",
            horizontalPosition,
            verticalPosition,
            "click",
            numberOfClicks));
    setOutputCommand();
  }
}
