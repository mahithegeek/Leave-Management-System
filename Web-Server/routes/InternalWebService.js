var roleResolver = require("./roleresolver.js");
var store = require("./storage.js");
var utilities = require("./Utilities.js");
var authentication = require("./OAuth2.js");
var sqlHandle,utils,auth,role;

//empty constructor
function InternalWebService (){

	sqlHandle = new store ();
	utils = new utilities ();
	auth = new authentication ();
	role = new roleResolver();
}

//To DO just check the credentials and see if this is a legitimate request
InternalWebService.prototype.getUsers = function getUsers (req,response) {
	
	var tokenCallback = function (err,email){
		if(err == null){
			var roleCallback = function (err,role){
			if(role == 2 || role == 3) {
				internalGetUsers (req,response);
			}
		 };
			role.fetchRole (email, roleCallback);
		}
		else {
			console.log (err);
			response.send(err);
		}
		
	};

	verifyTokenID (req.body.tokenID,tokenCallback);	
};

function internalGetUsers (req,response) {
	var callback = function (err,data) {
		if(err == null){
			response.send (JSON.stringify(data));
		}
		else {
			response.send (err);
		}
	}
	sqlHandle.getUserInfo(callback);
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

