package com.nicobrest.kamehouse.tennisworld.dao;

import com.nicobrest.kamehouse.commons.dao.AbstractCrudDaoJpa;
import com.nicobrest.kamehouse.commons.dao.CrudDao;
import com.nicobrest.kamehouse.tennisworld.model.TennisWorldUser;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * JPA DAO for TennisWorldUser entity.
 *
 * @author nbrest
 */
@Repository
public class TennisWorldUserDaoJpa extends AbstractCrudDaoJpa implements CrudDao<TennisWorldUser> {

  @Override
  public Long create(TennisWorldUser entity) {
    return create(TennisWorldUser.class, entity);
  }

  @Override
  public TennisWorldUser read(Long id) {
    return read(TennisWorldUser.class, id);
  }

  @Override
  public List<TennisWorldUser> readAll() {
    return readAll(TennisWorldUser.class);
  }

  @Override
  public void update(TennisWorldUser entity) {
    update(TennisWorldUser.class, entity);
  }

  @Override
  public TennisWorldUser delete(Long id) {
    return delete(TennisWorldUser.class, id);
  }

  @Override
  protected <T> void updateEntityValues(T persistedEntity, T entity) {
    TennisWorldUser persistedObject = (TennisWorldUser) persistedEntity;
    TennisWorldUser updatedObject = (TennisWorldUser) entity;
    persistedObject.setEmail(updatedObject.getEmail());
    persistedObject.setPassword(updatedObject.getPassword());
  }
}
