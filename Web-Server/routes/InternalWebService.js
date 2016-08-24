var store = require("./storage.js");
var utilities = require("./Utilities.js");
var authentication = require("./OAuth2.js");
var sqlHandle,utils,auth;

//empty constructor
function InternalWebService (){

	sqlHandle = new store ();
	utils = new utilities ();
	auth = new authentication ();
}

//To DO just check the credentials and see if this is a legitimate request
InternalWebService.prototype.getUsers = function getUsers (req,response) {
	sqlHandle.getUserInfo(function(data){console.log(JSON.stringify(data)); response.send(JSON.stringify(data));},function(eror){});
};

InternalWebService.prototype.getAvailableLeaves = function (req,response) {
	//TO-DO check if this is valid
	if(req.body.empid ) {
		sqlHandle.getAvailableLeaves(function (data) {response.send(JSON.stringify(data));},function(error){response.send(error);},req.body.empid);
	}
	else {
		response.send ("Invalid Employee ID");
	}
};

InternalWebService.prototype.applyLeave = function (req,response) {
	if(utils.validateDate(req.body.fromDate) && utils.validateDate(req.body.toDate)) {
		sqlHandle.insertLeaves (function (success){response.send ( "successfully applied");},function (error){response.send ( error);},req.body);
		
	}
	else {
		response.send ("Invalid dates");
	}
};

InternalWebService.prototype.login = function (req, response) {

	var successCallback = function (tokenEmail) {
		
		var verifyResponse = function(success){
			if(success){
				response.send ("Successfully Logged In");
			}
			else {
				response.send ("Unable to Find the User");
			}
		};
		validateEmailFromOAuthToken(tokenEmail,verifyResponse);
	};
	auth.verifyTokenID (req.body.tokenID,successCallback,function(error){response.send (error);});
}

function validateEmailFromOAuthToken (tokenEmail,successCallback) {
	sqlHandle.verifyUserExists (tokenEmail,successCallback);
}

module.exports = InternalWebService;

