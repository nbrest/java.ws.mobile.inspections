package com.nicobrest.kamehouse.tennisworld.controller;

import com.nicobrest.kamehouse.commons.controller.AbstractCrudControllerTest;
import com.nicobrest.kamehouse.tennisworld.model.TennisWorldUser;
import com.nicobrest.kamehouse.tennisworld.model.dto.TennisWorldUserDto;
import com.nicobrest.kamehouse.tennisworld.service.TennisWorldUserService;
import com.nicobrest.kamehouse.tennisworld.testutils.TennisWorldUserTestUtils;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.io.IOException;

/**
 * Unit tests for the TennisWorldUserController class.
 *
 * @author nbrest
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext.xml" })
@WebAppConfiguration
public class TennisWorldUserControllerTest
    extends AbstractCrudControllerTest<TennisWorldUser, TennisWorldUserDto> {

  private static final String API_V1_TENNISWORLD_USERS =
      TennisWorldUserTestUtils.API_V1_TENNISWORLD_USERS;

  private TennisWorldUser tennisWorldUser;

  @InjectMocks
  private TennisWorldUserController tennisWorldUserController;

  @Mock(name = "TennisWorldUserService")
  private TennisWorldUserService tennisWorldUserServiceMock;

  /**
   * Init test data.
   */
  @Before
  public void beforeTest() {
    testUtils = new TennisWorldUserTestUtils();
    testUtils.initTestData();
    testUtils.setIds();
    tennisWorldUser = testUtils.getSingleTestData();

    MockitoAnnotations.initMocks(this);
    Mockito.reset(tennisWorldUserServiceMock);
    mockMvc = MockMvcBuilders.standaloneSetup(tennisWorldUserController).build();
  }

  /**
   * Tests creating a new entity in the repository.
   */
  @Test
  public void createTest() throws Exception {
    createTest(API_V1_TENNISWORLD_USERS, tennisWorldUserServiceMock);
  }

  /**
   * Tests creating a new entity in the repository that already exists.
   */
  @Test
  public void createConflictExceptionTest() throws Exception {
    createConflictExceptionTest(API_V1_TENNISWORLD_USERS, tennisWorldUserServiceMock);
  }

  /**
   * Tests getting a specific entity from the repository.
   */
  @Test
  public void readTest() throws Exception {
    readTest(API_V1_TENNISWORLD_USERS, tennisWorldUserServiceMock, TennisWorldUser.class);
  }

  /**
   * Tests getting all the entities from the repository.
   */
  @Test
  public void readAllTest() throws Exception {
    readAllTest(API_V1_TENNISWORLD_USERS, tennisWorldUserServiceMock, TennisWorldUser.class);
  }

  /**
   * Tests updating an existing entity in the repository.
   */
  @Test
  public void updateTest() throws Exception {
    updateTest(API_V1_TENNISWORLD_USERS, tennisWorldUserServiceMock);
  }

  /**
   * Tests failing to update an existing entity in the repository with bad request.
   */
  @Test
  public void updateInvalidPathId() throws IOException, Exception {
    updateInvalidPathId(API_V1_TENNISWORLD_USERS);
  }

  /**
   * Tests trying to update a non existing entity in the repository.
   */
  @Test
  public void updateNotFoundExceptionTest() throws Exception {
    updateNotFoundExceptionTest(API_V1_TENNISWORLD_USERS, tennisWorldUserServiceMock);
  }

  /**
   * Tests for deleting an existing entity from the repository.
   */
  @Test
  public void deleteTest() throws Exception {
    deleteTest(API_V1_TENNISWORLD_USERS, tennisWorldUserServiceMock, TennisWorldUser.class);
  }

  /**
   * Tests for deleting an entity not found in the repository.
   */
  @Test
  public void deleteNotFoundExceptionTest() throws Exception {
    deleteNotFoundExceptionTest(API_V1_TENNISWORLD_USERS, tennisWorldUserServiceMock);
  }
}
