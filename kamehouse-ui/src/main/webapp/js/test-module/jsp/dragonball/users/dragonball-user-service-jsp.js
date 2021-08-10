/**
 * Functionality to manage the dragonball users in the UI through the jsps and servlet api.
 */
function DragonBallUserServiceJsp() {
  let self = this;
  var SERVLET_SERVICE_URI = '/kame-house-testmodule/api/v1/servlet/test-module/dragonball/users';

  /**
   * Get a dragonball user and populate it to the edit table.
   */
  this.getDragonBallUser = (event) => {
    logger.trace(arguments.callee.name);
    const urlParams = new URLSearchParams(window.location.search);
    const params = new URLSearchParams({
      username: urlParams.get('username')
    });
    let getUrl = SERVLET_SERVICE_URI + "?" + params;

    debuggerHttpClient.get(getUrl, 
      (responseBody, responseCode, responseDescription) => self.displayDragonBallUserToEdit(responseBody),
      (responseBody, responseCode, responseDescription) => {
        alert("Error getting dragonball user");
        logger.error("Error getting dragonball user " + responseBody + responseCode + responseDescription);
      }, null);
  }

  /**
   * Get all dragonball users.
   */
  this.getAllDragonBallUsers = () => {
    logger.trace(arguments.callee.name);
    debuggerHttpClient.get(SERVLET_SERVICE_URI, 
      (responseBody, responseCode, responseDescription) => self.displayDragonBallUsers(responseBody),
      (responseBody, responseCode, responseDescription) => self.displayErrorGettingDragonBallUsers(),
      null);
  }

  /**
   * Add a dragonball user.
   */
  this.addDragonBallUser = () => {
    logger.trace(arguments.callee.name);
    const params = new URLSearchParams({
      username: document.getElementById("input-username").value,
      email: document.getElementById("input-email").value,
      age: document.getElementById("input-age").value,
      powerLevel: document.getElementById("input-powerLevel").value,
      stamina: document.getElementById("input-stamina").value
    });

    debuggerHttpClient.postUrlEncoded(SERVLET_SERVICE_URI, params,
      (responseBody, responseCode, responseDescription) => {window.location.href = 'users-list'},
      (responseBody, responseCode, responseDescription) => {
        alert("Error adding dragonball user. Check console logs for more details");
        logger.error("Error adding dragonball user " + responseBody + responseCode + responseDescription);
      });
  }

  /**
   * Update a dragonball user.
   */
  this.updateDragonBallUser = () => {
    logger.trace(arguments.callee.name);
    const params = new URLSearchParams({
      id: document.getElementById("input-id").value,
      username: document.getElementById("input-username").value,
      email: document.getElementById("input-email").value,
      age: document.getElementById("input-age").value,
      powerLevel: document.getElementById("input-powerLevel").value,
      stamina: document.getElementById("input-stamina").value
    });

    debuggerHttpClient.putUrlEncoded(SERVLET_SERVICE_URI, params,
      (responseBody, responseCode, responseDescription) => {window.location.href = 'users-list'},
      (responseBody, responseCode, responseDescription) => {
        alert("Error updating dragonball user. Check console logs for more details");
        logger.error("Error updating dragonball user " + responseBody + responseCode + responseDescription);
      }, null);
  }

  /**
  * Delete dragonball user.
  */
  this.deleteDragonBallUser = (id) => {
    logger.trace(arguments.callee.name);
    const params = new URLSearchParams({
      id: id
    });

    debuggerHttpClient.deleteUrlEncoded(SERVLET_SERVICE_URI, params,
      (responseBody, responseCode, responseDescription) => self.getAllDragonBallUsers(),
      (responseBody, responseCode, responseDescription) => self.getAllDragonBallUsers(), 
      null);
  }

  /**
   * Display the dragonball user to edit.
   */
  this.displayDragonBallUserToEdit = (dragonBallUser) => {
    logger.trace(arguments.callee.name);
    document.getElementById("input-id").value = dragonBallUser.id;
    document.getElementById("input-username").value = dragonBallUser.username;
    document.getElementById("input-email").value = dragonBallUser.email;
    document.getElementById("input-age").value = dragonBallUser.age;
    document.getElementById("input-powerLevel").value = dragonBallUser.powerLevel;
    document.getElementById("input-stamina").value = dragonBallUser.stamina;
  }

  /**
   * Display dragonball users table.
   */
  this.displayDragonBallUsers = async (dragonBallUsersList) => {
    logger.trace(arguments.callee.name);
    let $dragonBallUsersTbody = $('#dragonball-users-tbody');
    domUtils.empty($dragonBallUsersTbody);
    domUtils.append($dragonBallUsersTbody, await self.getDragonBallUserTableHeader());
    for (let i = 0; i < dragonBallUsersList.length; i++) {
      domUtils.append($dragonBallUsersTbody, self.getDragonBallUserTableRow(dragonBallUsersList[i]));
    }
  }

  /**
   * Display dragonball users.
   */
  this.displayErrorGettingDragonBallUsers = () => {
    self.displayErrorTable("Error getting dragonball users from the backend");
  }

  /**
   * Display dragonball users.
   */
  this.displayErrorDeletingDragonBallUser = () => {
    self.displayErrorTable("Error deleting dragonball user from the backend");
  }

  /**
   * Shows the specified error message in the table.
   */
  this.displayErrorTable = (message) => {
    logger.trace(arguments.callee.name);
    let $dragonBallUsersTbody = $('#dragonball-users-tbody');
    domUtils.empty($dragonBallUsersTbody);
    domUtils.append($dragonBallUsersTbody, self.getErrorMessageTr(message));
  }
  
  this.getErrorMessageTr = (message) => {
    return domUtils.getTrTd(message);
  }

  this.getDragonBallUserTableRow = (dragonBallUser) => {
    let tr = domUtils.getTr({}, null);
    domUtils.append(tr, getDragonBallUserTd(dragonBallUser.id));
    domUtils.append(tr, getDragonBallUserTd(dragonBallUser.username));
    domUtils.append(tr, getDragonBallUserTd(dragonBallUser.email));
    domUtils.append(tr, getDragonBallUserTd(dragonBallUser.age));
    domUtils.append(tr, getDragonBallUserTd(dragonBallUser.powerLevel));
    domUtils.append(tr, getDragonBallUserTd(dragonBallUser.stamina));
    domUtils.append(tr, getActionButtonsTd(dragonBallUser.username, dragonBallUser.id));
    return tr;
  }

  function getDragonBallUserTd(dataValue) {
    return domUtils.getTd({}, dataValue);
  }

  function getActionButtonsTd(username, id) {
    let td = domUtils.getTd({}, null);
    domUtils.append(td, getEditButton(username));
    domUtils.append(td, getDeleteButton(id));
    return td; 
  }

  function getEditButton(username) {
    return domUtils.getImgBtn({
      src: "/kame-house/img/other/edit-green.png",
      className: "img-btn-kh m-15-d-r-kh",
      alt: "Edit",
      onClick: () => window.location.href="users-edit?username=" + username
    });
  }

  function getDeleteButton(id) {
    return domUtils.getImgBtn({
      src: "/kame-house/img/other/delete-red.png",
      className: "img-btn-kh",
      alt: "Delete",
      onClick: () => self.deleteDragonBallUser(id)
    });
  }

  this.getDragonBallUserTableHeader = () => {
    return domUtils.loadHtmlSnippet("/kame-house/html-snippets/test-module/dragonball-users-table-header.html");
  }
}
