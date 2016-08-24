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
		console.log("dates are valid");
		sqlHandle.insertLeaves (function (success){response.send ( "successfully applied");},function (error){response.send ( error);},req.body);
		
	}
	else {
		response.send ("Invalid dates");
	}
};

InternalWebService.prototype.login = function (req, response) {

	auth.verifyTokenID (req.body.tokenID,function(success){console.log("success");response.send("verified id");},function(error){response.send ("some error");});
}

module.exports = InternalWebService;

