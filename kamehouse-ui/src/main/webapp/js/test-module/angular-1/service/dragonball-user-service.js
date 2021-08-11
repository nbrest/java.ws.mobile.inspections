'use strict';

/**
 * DragonBallUserService.
 * 
 * @author nbrest
 */
angular.module('myApp').service('dragonBallUserService', [ '$http', '$q', function($http, $q) {

  var REST_SERVICE_URI = '/kame-house-testmodule/api/v1/test-module/dragonball/users/';

  var dragonBallUserService = {
    fetchAllDragonBallUsers: fetchAllDragonBallUsers,
    createDragonBallUser: createDragonBallUser,
    updateDragonBallUser: updateDragonBallUser,
    deleteDragonBallUser: deleteDragonBallUser
  };
  return dragonBallUserService;

  /**
   * Get all DragonBallUsers.
   */
  function fetchAllDragonBallUsers() {
    let deferred = $q.defer();
    $http.get(REST_SERVICE_URI)
      .then(
        (response) => deferred.resolve(response.data),
        (errResponse) => {
          console.error('Error while fetching all DragonBallUsers');
          deferred.reject(errResponse);
        }
    );
    return deferred.promise;
  }

  /**
   * Create a DragonBallUser.
   */
  function createDragonBallUser(dragonBallUser) {
    let deferred = $q.defer();
    let config = generateConfig();
    $http.post(REST_SERVICE_URI, dragonBallUser, config)
      .then(
        (response) => deferred.resolve(response.data),
        (errResponse) => {
          console.error('Error while creating DragonBallUser');
          deferred.reject(errResponse);
        }
    );
    return deferred.promise;
  }
  
  /**
   * Updates a DragonBallUser.
   */
  function updateDragonBallUser(dragonBallUser, id) {
    let deferred = $q.defer();
    let config = generateConfig();
    $http.put(REST_SERVICE_URI + id, dragonBallUser, config)
      .then(
        (response) => deferred.resolve(response.data),
        (errResponse) => {
          console.error('Error while updating DragonBallUser');
          deferred.reject(errResponse);
        }
    );
    return deferred.promise;
  }

  /**
   * Deletes a DragonBallUser.
   */
  function deleteDragonBallUser(id) {
    let deferred = $q.defer();
    let config = generateConfig();
    $http.delete(REST_SERVICE_URI + id, config)
      .then(
        (response) => deferred.resolve(response.data),
        (errResponse) => {
          console.error('Error while deleting DragonBallUser');
          deferred.reject(errResponse);
        }
    );
    return deferred.promise;
  }

  /**
   * Generate config object to pass to the http requests.
   */
  function generateConfig() {
    let config = {};
    config.headers = {};
    //console.log("config" + JSON.stringify(config));
    return config;
  }
}]);