package com.nicobrest.kamehouse.commons.validator;

import static org.junit.jupiter.api.Assertions.assertThrows;

import com.nicobrest.kamehouse.commons.exception.KameHouseInvalidDataException;
import org.junit.jupiter.api.Test;

/**
 * Test class for the InputValidator.
 *
 * @author nbrest
 */
public class InputValidatorTest {

  /** Tests valid string length. Should finish without throwing exceptions. */
  @Test
  public void validateStringLength() {
    InputValidator.validateStringLength("mada mada dane");
  }

  /** Tests the failure flow of validateStringLength. */
  @Test
  public void validateStringLengthExceptionTest() {
    assertThrows(
        KameHouseInvalidDataException.class,
        () -> {
          StringBuilder sb = new StringBuilder();
          for (int i = 0; i < 70; i++) {
            sb.append("goku");
          }
          String username = sb.toString();

          InputValidator.validateStringLength(username);
        });
  }
}
