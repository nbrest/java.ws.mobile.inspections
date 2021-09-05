package com.nicobrest.kamehouse.admin.dao;

import com.nicobrest.kamehouse.commons.dao.AbstractCrudDaoJpa;
import com.nicobrest.kamehouse.commons.model.KameHouseRole;
import com.nicobrest.kamehouse.commons.model.KameHouseUser;
import java.util.Iterator;
import java.util.Set;
import org.springframework.stereotype.Repository;

/**
 * JPA DAO for the KameHouseUser entities.
 *
 * @author nbrest
 */
@Repository
public class KameHouseUserDaoJpa extends AbstractCrudDaoJpa<KameHouseUser>
    implements KameHouseUserDao {

  @Override
  public Class<KameHouseUser> getEntityClass() {
    return KameHouseUser.class;
  }

  @Override
  protected <T> void updateEntityValues(T persistedEntity, T entity) {
    KameHouseUser persistedKameHouseUser = (KameHouseUser) persistedEntity;
    KameHouseUser updatedKameHouseUser = (KameHouseUser) entity;
    persistedKameHouseUser.setAccountNonExpired(updatedKameHouseUser.isAccountNonExpired());
    persistedKameHouseUser.setAccountNonLocked(updatedKameHouseUser.isAccountNonLocked());
    persistedKameHouseUser.setCredentialsNonExpired(updatedKameHouseUser.isCredentialsNonExpired());
    persistedKameHouseUser.setEmail(updatedKameHouseUser.getEmail());
    persistedKameHouseUser.setEnabled(updatedKameHouseUser.isEnabled());
    persistedKameHouseUser.setFirstName(updatedKameHouseUser.getFirstName());
    persistedKameHouseUser.setLastLogin(updatedKameHouseUser.getLastLogin());
    persistedKameHouseUser.setLastName(updatedKameHouseUser.getLastName());
    persistedKameHouseUser.setPassword(updatedKameHouseUser.getPassword());
    persistedKameHouseUser.setUsername(updatedKameHouseUser.getUsername());
    Set<KameHouseRole> persistedKameHouseRoles = persistedKameHouseUser.getAuthorities();
    Set<KameHouseRole> updatedKameHouseRoles = updatedKameHouseUser.getAuthorities();
    Iterator<KameHouseRole> persistedApplicationRolesIterator = persistedKameHouseRoles.iterator();
    while (persistedApplicationRolesIterator.hasNext()) {
      KameHouseRole persistedRole = persistedApplicationRolesIterator.next();
      if (!updatedKameHouseRoles.contains(persistedRole)) {
        persistedApplicationRolesIterator.remove();
      }
    }
    persistedKameHouseRoles.addAll(updatedKameHouseRoles);
  }

  @Override
  public KameHouseUser loadUserByUsername(String username) {
    logger.trace("loadUserByUsername {}", username);
    KameHouseUser kameHouseUser = findByUsername(KameHouseUser.class, username);
    logger.trace("loadUserByUsername {} response {}", username, kameHouseUser);
    return kameHouseUser;
  }
}
