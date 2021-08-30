package com.nicobrest.kamehouse.vlcrc.dao;

import static org.junit.jupiter.api.Assertions.assertThrows;
import com.nicobrest.kamehouse.commons.dao.AbstractCrudDaoJpaTest;
import com.nicobrest.kamehouse.commons.exception.KameHouseNotFoundException;
import com.nicobrest.kamehouse.vlcrc.model.VlcPlayer;
import com.nicobrest.kamehouse.vlcrc.model.dto.VlcPlayerDto;
import com.nicobrest.kamehouse.vlcrc.testutils.VlcPlayerTestUtils;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import java.lang.reflect.InvocationTargetException;

/**
 * Unit tests for the VlcPlayerDaoJpa class.
 *
 * @author nbrest
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext.xml" })
public class VlcPlayerDaoJpaTest extends AbstractCrudDaoJpaTest<VlcPlayer, VlcPlayerDto> {

  private VlcPlayer vlcPlayer;

  @Autowired
  private VlcPlayerDao vlcPlayerDaoJpa;

  /**
   * Clears data from the repository before each test.
   */
  @BeforeEach
  public void setUp() {
    testUtils = new VlcPlayerTestUtils();
    testUtils.initTestData();
    testUtils.removeIds();
    vlcPlayer = testUtils.getSingleTestData();

    clearTable("VLC_PLAYER");
  }

  /**
   * Tests creating a VlcPlayer in the repository.
   */
  @Test
  public void createTest() {
    createTest(vlcPlayerDaoJpa, VlcPlayer.class);
  }

  /**
   * Tests creating a VlcPlayer in the repository Exception flows.
   */
  @Test
  public void createConflictExceptionTest() {
    createConflictExceptionTest(vlcPlayerDaoJpa);
  }

  /**
   * Tests getting a single entity from the repository by id.
   */
  @Test
  public void readTest() {
    readTest(vlcPlayerDaoJpa);
  }

  /**
   * Tests getting all the VlcPlayers in the repository.
   */
  @Test
  public void readAllTest() {
    readAllTest(vlcPlayerDaoJpa);
  }

  /**
   * Tests updating an existing user in the repository.
   */
  @Test
  public void updateTest() {
    VlcPlayer updatedEntity = new VlcPlayer();
    updatedEntity.setPassword(vlcPlayer.getPassword());
    updatedEntity.setId(vlcPlayer.getId());
    updatedEntity.setPort(vlcPlayer.getPort());
    updatedEntity.setUsername(vlcPlayer.getUsername());
    updatedEntity.setHostname("kamehameha-updated-hostname");

    updateTest(vlcPlayerDaoJpa, VlcPlayer.class, updatedEntity);
  }

  /**
   * Tests updating an existing entity in the repository Exception flows.
   */
  @Test
  public void updateNotFoundExceptionTest() {
    updateNotFoundExceptionTest(vlcPlayerDaoJpa, VlcPlayer.class);
  }

  /**
   * Tests deleting an existing entity from the repository.
   */
  @Test
  public void deleteTest() {
    deleteTest(vlcPlayerDaoJpa);
  }

  /**
   * Tests deleting an existing entity from the repository Exception flows.
   */
  @Test
  public void deleteNotFoundExceptionTest() {
    deleteNotFoundExceptionTest(vlcPlayerDaoJpa, VlcPlayer.class);
  }

  /**
   * Tests getting a single VlcPlayer in the repository by hostname.
   */
  @Test
  public void getByHostnameTest() {
    persistEntityInRepository(vlcPlayer);

    VlcPlayer returnedEntity = vlcPlayerDaoJpa.getByHostname(vlcPlayer.getHostname());

    testUtils.assertEqualsAllAttributes(vlcPlayer, returnedEntity);
  }

  /**
   * Tests getting a single VlcPlayer in the repository Exception flows.
   */
  @Test
  public void getByHostnameNotFoundExceptionTest() {
    assertThrows(KameHouseNotFoundException.class, () -> {
      vlcPlayerDaoJpa.getByHostname(VlcPlayerTestUtils.INVALID_HOSTNAME);
    });
  }
}
