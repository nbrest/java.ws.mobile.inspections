package com.nicobrest.kamehouse.commons.utils;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

import com.nicobrest.kamehouse.commons.model.TestDaemonCommand;
import com.nicobrest.kamehouse.commons.model.systemcommand.SystemCommand.Output;
import com.nicobrest.kamehouse.commons.testutils.SystemCommandOutputTestUtils;
import java.io.IOException;
import java.util.Properties;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.MockedStatic;
import org.mockito.Mockito;

/**
 * DockerUtils tests.
 *
 * @author nbrest
 */
public class DockerUtilsTest {

  private SystemCommandOutputTestUtils testUtils = new SystemCommandOutputTestUtils();
  private MockedStatic<PropertiesUtils> propertiesUtils;
  private MockedStatic<SshClientUtils> sshClientUtils;

  /**
   * Tests setup.
   */
  @BeforeEach
  public void before() throws IOException {
    testUtils.initTestData();
    propertiesUtils = Mockito.mockStatic(PropertiesUtils.class);
    sshClientUtils = Mockito.mockStatic(SshClientUtils.class);
  }

  /**
   * Tests cleanup.
   */
  @AfterEach
  public void close() {
    propertiesUtils.close();
    sshClientUtils.close();
  }

  /**
   * Execute command on docker host successful test.
   */
  @Test
  public void executeOnDockerHostTest() {
    when(SshClientUtils.execute(any(), any(), any())).thenReturn(testUtils.getSingleTestData());

    Output output = DockerUtils.executeOnDockerHost(new TestDaemonCommand("1"));

    assertEquals(testUtils.getSingleTestData(), output);
  }

  /**
   * shouldExecuteOnDockerHost test.
   */
  @Test
  public void shouldExecuteOnDockerHostTest() {
    when(PropertiesUtils.getBooleanProperty("IS_DOCKER_CONTAINER")).thenReturn(true);
    when(PropertiesUtils.getBooleanProperty("DOCKER_CONTROL_HOST")).thenReturn(true);

    assertTrue(DockerUtils.shouldExecuteOnDockerHost(new TestDaemonCommand("1")));
  }

  /**
   * isWindowsDockerHost test.
   */
  @Test
  public void isWindowsDockerHostTest() {
    when(PropertiesUtils.getProperty("DOCKER_HOST_OS")).thenReturn("windows");

    assertTrue(DockerUtils.isWindowsDockerHost());
  }

  /**
   * isDockerContainer test.
   */
  @Test
  public void isDockerContainerTest() {
    when(PropertiesUtils.getBooleanProperty("IS_DOCKER_CONTAINER")).thenReturn(true);

    assertTrue(DockerUtils.isDockerContainer());
  }

  /**
   * isDockerControlHostEnabled test.
   */
  @Test
  public void isDockerControlHostEnabledTest() {
    when(PropertiesUtils.getBooleanProperty("DOCKER_CONTROL_HOST")).thenReturn(true);

    assertTrue(DockerUtils.isDockerControlHostEnabled());
  }

  /**
   * getDockerHostIp test.
   */
  @Test
  public void getDockerHostIpTest() {
    when(PropertiesUtils.getProperty("DOCKER_HOST_IP")).thenReturn("192.168.0.99");

    assertEquals("192.168.0.99", DockerUtils.getDockerHostIp());
  }

  /**
   * getDockerHostUsername test.
   */
  @Test
  public void getDockerHostUsernameTest() {
    when(PropertiesUtils.getProperty("DOCKER_HOST_USERNAME")).thenReturn("goku");

    assertEquals("goku", DockerUtils.getDockerHostUsername());
  }

  /**
   * getDockerContainerProperties test.
   */
  @Test
  public void getDockerContainerPropertiesTest() {
    //TODO mock user home to load the file from test resources as I did in other tests
    Properties properties = DockerUtils.getDockerContainerProperties();

    assertNotNull(properties);
  }
}
