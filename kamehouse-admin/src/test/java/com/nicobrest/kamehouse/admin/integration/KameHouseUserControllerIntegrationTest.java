package com.nicobrest.kamehouse.admin.integration;

import com.nicobrest.kamehouse.commons.integration.AbstractCrudControllerIntegrationTest;
import com.nicobrest.kamehouse.commons.model.KameHouseUser;
import com.nicobrest.kamehouse.commons.model.dto.KameHouseUserDto;
import com.nicobrest.kamehouse.commons.testutils.KameHouseUserTestUtils;
import org.apache.commons.lang3.RandomStringUtils;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;

/**
 * Integration tests for the KameHouseUserController class.
 *
 * @author nbrest
 */
public class KameHouseUserControllerIntegrationTest
    extends AbstractCrudControllerIntegrationTest<KameHouseUser, KameHouseUserDto> {

  @Override
  public String getWebapp() {
    return "/kame-house-admin";
  }

  @Override
  public String getCrudSuffix() {
    return KameHouseUserTestUtils.API_V1_ADMIN_KAMEHOUSE_USERS;
  }

  @Override
  public Class<KameHouseUser> getEntityClass() {
    return KameHouseUser.class;
  }

  @Override
  public Class<KameHouseUserDto> getDtoClass() {
    return KameHouseUserDto.class;
  }

  @Override
  public void initTestUtils() {
    testUtils = new KameHouseUserTestUtils();
    testUtils.initTestData();
  }

  @Override
  public KameHouseUser createEntity() {
    KameHouseUser kameHouseUser = testUtils.getSingleTestData();
    String randomUsername = RandomStringUtils.randomAlphabetic(12);
    kameHouseUser.setUsername(randomUsername);
    kameHouseUser.setEmail(randomUsername + "@dbz.com");
    return kameHouseUser;
  }

  @Override
  public void updateEntity(KameHouseUser entity) {
    entity.setFirstName(RandomStringUtils.randomAlphabetic(12));
  }

  /**
   * Gets an kamehouse user.
   */
  @Test
  @Order(5)
  public void loadUserByUsernameTest() throws Exception {
    logger.info("Running loadUserByUsernameTest");
  }

  /**
   * Tests get user not found exception.
   */
  @Test
  @Order(5)
  public void loadUserByUsernameNotFoundExceptionTest() throws Exception {
    logger.info("Running loadUserByUsernameTest");
  }
}
