var store = require("./storage.js");
var utils = require("./Utilities.js");
var sqlHandle,utils;

//empty constructor
function InternalWebService (){

	sqlHandle = new store ();
	utils = new utils ();
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

module.exports = InternalWebService;

