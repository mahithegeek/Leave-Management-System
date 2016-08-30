var accessResolver = require("./accessresolver.js");
var store = require("./storage.js");
var utilities = require("./Utilities.js");
var authentication = require("./OAuth2.js");
var sqlHandle,utils,auth,access;

//empty constructor
function InternalWebService (){

	sqlHandle = new store ();
	utils = new utilities ();
	auth = new authentication ();
	access = new accessResolver();
}

//To DO just check the credentials and see if this is a legitimate request
InternalWebService.prototype.getUsers = function getUsers (req,response) {
	var accessCallback = function (err, user) {
		if(err == null) {
			if(user.role_id == 2 || user.role_id == 3 || user.role_id == 0){
				internalGetUsers (req,response,user.emp_id);
			}
			else {
				response.status(500).send ("User has no access to this API");
			}
		}
		else {
			response.status(500).send(err);
		}
	};

	//console.log(req.body.tokenID);
	access.determineUser (req.body.tokenID, accessCallback);
};

function internalGetUsers (req,response,superviosrID) {
	var callback = function (err,data) {
		if(err == null){
			response.send (JSON.stringify(data));
		}
		else {
			response.status(500).send (err);
		}
	}
	sqlHandle.getUserInfo(superviosrID,callback);
}

InternalWebService.prototype.getAvailableLeaves = function (req,response) {
	//TO-DO check if this is valid
	if(req.body.empid ) {
		
		var callback = function (err,data){
			if (err == null) {
				response.send(JSON.stringify(data));
			}
			else {
				response.send(error);
			}
		}
		sqlHandle.getAvailableLeaves(req.body.empid,callback);
	}
	else {
		response.send ("Invalid Employee ID");
	}
};

InternalWebService.prototype.applyLeave = function (req,response) {
	if(utils.validateDate(req.body.fromDate) && utils.validateDate(req.body.toDate)) {
		var callback = function (err,data) {
			if(err == null){
				response.send("Leave Application Successfull");
			}
			else {
				response.send(error);
			}
		}
		sqlHandle.insertLeaves (req.body,callback);
		
	}
	else {
		response.send ("Invalid dates");
	}
};

InternalWebService.prototype.login = function (req, response) {

	var callback = function (err,tokenEmail) {
		if(err == null){
			//now that token is validated from google service, verify if the user existst in our db
			var verifyResponse = function(err,success){
			if(err == null && success){
				response.send ("Successfully Logged In");
			}
			else {
				response.send ("Unable to Find the User");
			}
		};
			validateEmailFromOAuthToken(tokenEmail,verifyResponse);
		}
		else {
			response.send(err);
		}
	};
	verifyTokenID (req.body.tokenID,callback);
};

function verifyTokenID (tokenID,callback) {
	auth.verifyTokenID (tokenID,callback);
}

function validateEmailFromOAuthToken (tokenEmail,callback) {
	sqlHandle.verifyUserExists (tokenEmail,callback);
}

module.exports = InternalWebService;

