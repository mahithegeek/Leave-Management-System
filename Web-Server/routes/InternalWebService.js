var accessResolver = require("./accessresolver.js");
var store = require("./storage.js");
var utilities = require("./Utilities.js");
var authentication = require("./OAuth2.js");
var Error = require("./error.js");
var sqlHandle,utils,auth,access,error;

//empty constructor
function InternalWebService (){

	sqlHandle = new store ();
	utils = new utilities ();
	auth = new authentication ();
	access = new accessResolver();
	error = new Error();

}

InternalWebService.prototype.login = function (req, response) {

	var accessCallback = function (err, user) {
		console.log("callback triggered");
		if(err == null ) {
			console.log("creating user" + user);
			var userData = {firstName : user.firstName, lastName: user.lastName,email : user.email, empID : user.emp_id.toString(), role : user.role};
			response.setHeader('Content-Type', 'application/json');
			response.json(userData);
			
		}
		else {
			response.status(500).send(error.DatabaseError(err));
		}
	};

	//console.log(req.body.tokenID);
	access.determineUser (req.body.tokenID, accessCallback);
};

//To DO just check the credentials and see if this is a legitimate request
InternalWebService.prototype.getUsers = function getUsers (req,response) {
	var accessCallback = function (err, user) {
		if(err == null) {
			if(user.role_id == 2 || user.role_id == 3){
				internalGetUsers (req,response,user.emp_id);
			}
			else {
				response.status(400).send (error.UserAccessDeniedError());
			}
		}
		else {
			console.log(err);
			response.status(500).send(error.DatabaseError(err));
			//response.status( 500);
			//response.send ('error', {message : err.message,error: err});
		}
	};

	//console.log(req.body.tokenID);
	access.determineUser (req.body.tokenID, accessCallback);
};

function internalGetUsers (req,response,supervisorID) {
	var callback = function (err,data) {
		if(err == null){
			response.send (JSON.stringify(data));
		}
		else {
			response.status(500).send (error.DatabaseError(err));
		}
	}
	sqlHandle.getUserInfo(supervisorID,callback);
}

InternalWebService.prototype.getAvailableLeaves = function (req,response) {
	//TO-DO check if this is valid
	var accessCallback = function (err, user) {
		if(err == null) {
			console.log("user is    " + user.emp_id);
			if(user.role_id == 2 || user.role_id == 3 || user.role_id == 0 || user.role_id == 1){
				getLeavesForUser (req,response,user.emp_id);
			}
			else {
				response.status(400).send (error.UserAccessDeniedError());
			}
		}
		else {
			response.status(500).send(error.DatabaseError(err));
		}
	};

	access.determineUser (req.body.tokenID, accessCallback);
};

function getLeavesForUser (req,response,empID) {
	var callback = function (err,data){
			if (err == null) {
				console.log("successfully retrieved leaves");
				response.send(JSON.stringify(data));
			}
			else {
				console.log("error in getting leaves");
				response.status(500).send(error.DatabaseError(err));
			}
		}
		sqlHandle.getAvailableLeaves(empID,callback);
}

InternalWebService.prototype.applyLeave = function (req,response) {

	var accessCallback = function (err, user) {
		if(err == null) {
			if(user.role_id == 2 || user.role_id == 3 || user.role_id == 0 || user.role_id == 1){
				internalApplyLeave (req,response,req.body.leave,user);
			}
			else {
				response.status(400).send (error.UserAccessDeniedError());
			}
		}
		else {
			response.status(500).send(error.DatabaseError(err));
		}
	};
	access.determineUser (req.body.tokenID, accessCallback);
};

function internalApplyLeave (req,response,leaveRequestReceived,user) {
	if(utils.validateDate(req.body.fromDate) && utils.validateDate(req.body.toDate)) {
		var callback = function (err,data) {
			if(err == null){
				response.send("Leave Application Successfull");
			}
			else {
				response.send(error.DatabaseError(err));
			}
		}
		var leave = constructLeaveRequest(leaveRequestReceived,user);
		sqlHandle.insertLeaves (leave,callback);
		
	}
	else {
		response.status(400).send (new Error("Invalid dates"));
	}
}

function constructLeaveRequest (leaveRequestReceived,user) {
	var date = utils.getFormattedDate (new Date());
    var dbRequestObject = {date_from : leaveRequestReceived.fromDate,date_to : leaveRequestReceived.toDate, half_Day : leaveRequestReceived.isHalfDay,applied_on : date, status_id : 0,type_id : leaveRequestReceived.typeid,emp_id : user.emp_id};
    //console.log(dbRequestObject.date_from);
    return dbRequestObject;
}


InternalWebService.prototype.getLeaveRequests = function (req,response) {
	console.log("getLeaveRequests");
	var accessCallback = function (err, user) {
		if(err == null) {
			if(user.role == 2 || user.role == 3){
				internalGetLeaveRequests (req,response,user.empID);
			}
			else {
				console.log("bad req");
				response.status(400).send (error.UserAccessDeniedError());
			}
		}
		else {
			response.status(500).send(error.DatabaseError(err));
		}
	};
	access.determineUser (req.body.tokenID, accessCallback);
};

function internalGetLeaveRequests (req,response,empID) {
	console.log("internalGetLeaveRequests");
	var callback = function (err,data){
			if (err == null) {
				response.send(JSON.stringify(data));
			}
			else {
				response.status(500).send(error.DatabaseError(err));
			}
		}
		sqlHandle.fetchLeaveRequests(empID,callback);
}



module.exports = InternalWebService;

