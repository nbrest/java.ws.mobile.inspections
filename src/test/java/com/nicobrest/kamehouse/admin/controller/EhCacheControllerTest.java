package com.nicobrest.kamehouse.admin.controller;

import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.hasSize;
import static org.junit.Assert.fail;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.nicobrest.kamehouse.admin.controller.EhCacheController;
import com.nicobrest.kamehouse.admin.service.EhCacheService;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Unit tests for the EhCacheController class.
 *
 * @author nbrest
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext.xml" })
@WebAppConfiguration
public class EhCacheControllerTest {

  private MockMvc mockMvc;

  private static List<Map<String, Object>> cacheList;
  private static Map<String, Object> cacheMap;

  @InjectMocks
  private EhCacheController ehCacheController;

  @Mock(name = "ehCacheService")
  private EhCacheService ehCacheServiceMock;

  /**
   * Initializes test repositories.
   */
  @BeforeClass
  public static void beforeClassTest() {

    cacheList = new LinkedList<Map<String, Object>>();
    cacheMap = new HashMap<String, Object>();
    cacheMap.put("name", "getAllDragonBallUsersCache");
    cacheMap.put("keys", "[]");
    cacheMap.put("values", "[ ]");
    cacheMap.put("status", "STATUS_ALIVE");
    cacheList.add(cacheMap);
  }

  /**
   * Resets mock objects.
   */
  @Before
  public void beforeTest() {
    MockitoAnnotations.initMocks(this);
    Mockito.reset(ehCacheServiceMock);
    mockMvc = MockMvcBuilders.standaloneSetup(ehCacheController).build();
  }

  /**
   * Test getting all caches.
   */
  @Test
  public void getCacheTest() {

    when(ehCacheServiceMock.getAll()).thenReturn(cacheList);
    when(ehCacheServiceMock.get("getAllDragonBallUsersCache")).thenReturn(cacheMap);
    try {
      ResultActions requestResult = mockMvc.perform(get("/api/v1/admin/ehcache")).andDo(print());
      requestResult.andExpect(status().isOk());
      requestResult.andExpect(content().contentType("application/json;charset=UTF-8"));
      requestResult.andExpect(jsonPath("$", hasSize(1)));
      requestResult.andExpect(jsonPath("$[0].name", equalTo("getAllDragonBallUsersCache")));
      requestResult.andExpect(jsonPath("$[0].keys", equalTo("[]")));
      requestResult.andExpect(jsonPath("$[0].values", equalTo("[ ]")));
      requestResult.andExpect(jsonPath("$[0].status", equalTo("STATUS_ALIVE")));

      requestResult = mockMvc.perform(get("/api/v1/admin/ehcache?name=getAllDragonBallUsersCache"))
          .andDo(print());
      requestResult.andExpect(status().isOk());
      requestResult.andExpect(content().contentType("application/json;charset=UTF-8"));
      requestResult.andExpect(jsonPath("$", hasSize(1)));
      requestResult.andExpect(jsonPath("$[0].name", equalTo("getAllDragonBallUsersCache")));
      requestResult.andExpect(jsonPath("$[0].keys", equalTo("[]")));
      requestResult.andExpect(jsonPath("$[0].values", equalTo("[ ]")));
      requestResult.andExpect(jsonPath("$[0].status", equalTo("STATUS_ALIVE")));
    } catch (Exception e) {
      e.printStackTrace();
      fail("Unexpected exception thrown.");
    }
    verify(ehCacheServiceMock, times(1)).getAll();
    verify(ehCacheServiceMock, times(1)).get("getAllDragonBallUsersCache");
    verifyNoMoreInteractions(ehCacheServiceMock);
  }

  /**
   * Test clearing all caches.
   */
  @Test
  public void clearCacheTest() {

    try {
      ResultActions requestResult = mockMvc.perform(delete("/api/v1/admin/ehcache")).andDo(print());
      requestResult.andExpect(status().isOk());

      requestResult = mockMvc
          .perform(delete("/api/v1/admin/ehcache?name=getAllDragonBallUsersCache")).andDo(print());
      requestResult.andExpect(status().isOk());
    } catch (Exception e) {
      e.printStackTrace();
      fail("Unexpected exception thrown.");
    }
    verify(ehCacheServiceMock, times(1)).clearAll();
    verify(ehCacheServiceMock, times(1)).clear("getAllDragonBallUsersCache");
    verifyNoMoreInteractions(ehCacheServiceMock);
  }
}
