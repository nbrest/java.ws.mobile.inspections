package com.nicobrest.kamehouse.testmodule.service;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.nicobrest.kamehouse.testmodule.dao.DragonBallUserDao;
import com.nicobrest.kamehouse.testmodule.model.DragonBallUser;
import com.nicobrest.kamehouse.testmodule.service.dto.DragonBallUserDto;
import com.nicobrest.kamehouse.testmodule.testutils.DragonBallUserTestUtils;

import org.junit.Before;
import org.junit.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

import java.util.List;

/**
 * Unit tests for the DragonBallUserService class.
 *
 * @author nbrest
 */
public class DragonBallUserServiceTest {

  private static DragonBallUser dragonBallUser;
  private static DragonBallUserDto dragonBallUserDto;
  private static List<DragonBallUser> dragonBallUsersList;

  @InjectMocks
  private DragonBallUserService dragonBallUserService;

  @Mock(name = "dragonBallUserDao")
  private DragonBallUserDao dragonBallUserDaoMock;

  /**
   * Resets mock objects and initializes test repository.
   */
  @Before
  public void beforeTest() {
    DragonBallUserTestUtils.initTestData();
    DragonBallUserTestUtils.setIds();
    dragonBallUser = DragonBallUserTestUtils.getSingleTestData();
    dragonBallUserDto = DragonBallUserTestUtils.getTestDataDto();
    dragonBallUsersList = DragonBallUserTestUtils.getTestDataList();

    // Reset mock objects before each test
    MockitoAnnotations.initMocks(this);
    Mockito.reset(dragonBallUserDaoMock);
  }

  /**
   * Test for calling the service to create a DragonBallUser in the repository.
   */
  @Test
  public void createDragonBallUserTest() {
    Mockito.doReturn(dragonBallUser.getId()).when(dragonBallUserDaoMock)
        .create(dragonBallUser);

    Long createdId = dragonBallUserService.create(dragonBallUserDto);

    assertEquals(dragonBallUser.getId(), createdId);
    verify(dragonBallUserDaoMock, times(1)).create(dragonBallUser);
  }

  /**
   * Test for calling the service to get a single DragonBallUser in the repository
   * by id.
   */
  @Test
  public void getDragonBallUserTest() {
    when(dragonBallUserDaoMock.read(dragonBallUser.getId()))
        .thenReturn(dragonBallUser);

    DragonBallUser returnedUser = dragonBallUserService.read(dragonBallUser.getId());

    assertEquals(dragonBallUser, returnedUser);
    verify(dragonBallUserDaoMock, times(1)).read(dragonBallUser.getId());
  }

  /**
   * Test for calling the service to get a single DragonBallUser in the repository
   * by username.
   */
  @Test
  public void getDragonBallUserByUsernameTest() {
    when(dragonBallUserDaoMock.getByUsername(dragonBallUser.getUsername()))
        .thenReturn(dragonBallUser);

    DragonBallUser returnedUser =
        dragonBallUserService.getByUsername(dragonBallUser.getUsername());

    assertEquals(dragonBallUser, returnedUser);
    verify(dragonBallUserDaoMock, times(1)).getByUsername(dragonBallUser.getUsername());
  }

  /**
   * Test for calling the service to get a single DragonBallUser in the repository
   * by its email.
   */
  @Test
  public void getDragonBallUserByEmailTest() {
    when(dragonBallUserDaoMock.getByEmail(dragonBallUser.getEmail()))
        .thenReturn(dragonBallUser);

    DragonBallUser returnedUser =
        dragonBallUserService.getByEmail(dragonBallUser.getEmail());

    assertEquals(dragonBallUser, returnedUser);
    verify(dragonBallUserDaoMock, times(1)).getByEmail(dragonBallUser.getEmail());
  }

  /**
   * Test for calling the service to update an existing DragonBallUser in the
   * repository.
   */
  @Test
  public void updateDragonBallUserTest() {
    Mockito.doNothing().when(dragonBallUserDaoMock).update(dragonBallUser);

    dragonBallUserService.update(dragonBallUserDto);

    verify(dragonBallUserDaoMock, times(1)).update(dragonBallUser);
  }

  /**
   * Test for calling the service to delete an existing user in the repository.
   */
  @Test
  public void deleteDragonBallUserTest() {
    when(dragonBallUserDaoMock.delete(dragonBallUser.getId()))
        .thenReturn(dragonBallUser);

    DragonBallUser deletedUser = dragonBallUserService.delete(dragonBallUser.getId());

    assertEquals(dragonBallUser, deletedUser);
    verify(dragonBallUserDaoMock, times(1)).delete(dragonBallUser.getId());
  }

  /**
   * Test for calling the service to get all the DragonBallUsers in the
   * repository.
   */
  @Test
  public void getAllDragonBallUsersTest() {
    when(dragonBallUserDaoMock.getAll()).thenReturn(dragonBallUsersList);

    List<DragonBallUser> returnedList = dragonBallUserService.getAll();

    assertEquals(dragonBallUsersList, returnedList);
    verify(dragonBallUserDaoMock, times(1)).getAll();
  }
}
