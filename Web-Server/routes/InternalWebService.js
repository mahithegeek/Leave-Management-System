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

var ROLE = {
	ADMIN : 0,
	EMPLOYEE : 1,
	SUPERVISOR : 2,
	MANAGER : 3
};

InternalWebService.prototype.login = function (req, response) {

	var accessCallback = function (err, user) {
		console.log("callback triggered");
		if(err == null ) {
			var userData = {firstName : user.firstName, lastName: user.lastName,email : user.email, empID : user.emp_id.toString(), role : user.role,supervisorID : user.supervisor_id.toString(),supervisor:""};
			/*response.setHeader('Content-Type', 'application/json');
			response.json(userData);*/
			getSupervisorDetails (userData,response);
			
		}
		else {
			response.status(500).send(error.DatabaseError(err));
		}
	};

	//console.log(req.body.tokenID);
	access.determineUser (req.body.tokenID, accessCallback);
};

function getSupervisorDetails(user,response) {
	var callback = function (err,data) {
		if(err == null){
			
			console.log("count is " + data.length);
			if(data.length > 0){
				user.supervisor = data[0];
				console.log("supervisor is " + user.supervisor);
				response.json (user);
			}
			else {
				response.status(500).send(error.SuperVisorNotFound());
			}
		}
		else {
			response.status(500).send (error.DatabaseError(err));
		}
	}
	console.log("user details are " + user.supervisorID);
	sqlHandle.fetchSuperVisor(user.supervisorID,callback);
}

//To DO just check the credentials and see if this is a legitimate request
InternalWebService.prototype.getUsers = function getUsers (req,response) {
	console.log("API getUsers");
	var accessCallback = function (err, user) {
		if(err == null) {
			var userRole = getUserRole (user.role_id);
			if(userRole == ROLE.SUPERVISOR || userRole == ROLE.MANAGER){
				internalGetUsers (req,response,user.emp_id);
			}
			else {
				response.status(400).send (error.UserAccessDeniedError());
			}
		}
		else {
			console.log(err);
			response.status(500).send(error.DatabaseError(err));
		}
	};

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
	console.log("API getAvailableLeaves");
	//TO-DO check if this is valid
	var accessCallback = function (err, user) {
		if(err == null) {
			var userRole = getUserRole (user.role_id);
			if(userRole == ROLE.SUPERVISOR || userRole == ROLE.MANAGER || userRole == ROLE.EMPLOYEE){
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
				if(data.length > 0){
					response.send(JSON.stringify(data));
				}
				else{
					response.status(500).send(error.DatabaseError(err));
				}
				
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
			var userRole = getUserRole (user.role_id);
			if(userRole == ROLE.SUPERVISOR || userRole == ROLE.MANAGER || userRole == ROLE.EMPLOYEE){
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
	if(utils.validateDate(leaveRequestReceived.fromDate) && utils.validateDate(leaveRequestReceived.toDate)) {
		var callback = function (err,data) {
			if(err == null){
				var successResponse = {success : "Successfully applied Leave"};
				response.send(successResponse);
			}
			else {
				response.send(error.DatabaseError(err));
			}
		}
		var leave = constructLeaveRequest(leaveRequestReceived,user);
		sqlHandle.insertLeaves (leave,callback);
		
	}
	else {
		response.status(400).send (error.InputError("Invalid Dates"));
	}
}

function constructLeaveRequest (leaveRequestReceived,user) {
	var date = utils.getFormattedDate (new Date());
	var numberOfDays = utils.getWorkingDays(leaveRequestReceived.fromDate,leaveRequestReceived.toDate);
	console.log("number of days "+ numberOfDays);

    var dbRequestObject = {date_from : leaveRequestReceived.fromDate,date_to : leaveRequestReceived.toDate, half_Day : leaveRequestReceived.isHalfDay,applied_on : date, status_id : 0,type_id : leaveRequestReceived.typeid,emp_id : user.emp_id,days : numberOfDays};
    console.log(numberOfDays);
    return dbRequestObject;
}


InternalWebService.prototype.getLeaveRequests = function (req,response) {
	console.log("getLeaveRequests");
	var accessCallback = function (err, user) {
		if(err == null) {
			var userRole = getUserRole (user.role_id);
			if(userRole == ROLE.SUPERVISOR || userRole == ROLE.MANAGER){
				internalGetLeaveRequests (req,response,user.emp_id);
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

function internalGetLeaveRequests (req,response,empID) {
	console.log("internalGetLeaveRequests and emp id is  "+empID);
	var callback = function (err,data){
			if (err == null) {
				//response.send(JSON.stringify(data));
				var requests = formLeaveRequestResponse(data);
				response.send({leaverequests:requests});
			}
			else {
				response.status(500).send(error.DatabaseError(err));
			}
	}
		sqlHandle.fetchLeaveRequests(empID,callback);
}

function formLeaveRequestResponse (dbResult) {
	
	var leaveRequestResponse = [];
	for(var i=0;i< dbResult.length;i++){
		console.log("dbresult is  "+dbResult[i]);
		var leaveRequest = {id:dbResult[i].id,firstName:dbResult[i].first_name,lastName:dbResult[i].last_name,email:dbResult[i].email,fromDate:dbResult[i].date_from,toDate:dbResult[i].date_to,half_Day:dbResult[i].half_Day,appliedOn:dbResult[i].applied_on,status:dbResult[i].status};
		console.log("leave request is   "+ leaveRequest);
		leaveRequestResponse.push(leaveRequest);

	}
	
	return leaveRequestResponse;
}

InternalWebService.prototype.getLeaveHistory = function getLeaveHistory (req,response) {
	var accessCallback = function (err, user) {
		if(err == null) {
			var userRole = getUserRole (user.role_id);
			if(userRole == ROLE.SUPERVISOR || userRole == ROLE.MANAGER || userRole == ROLE.EMPLOYEE){
				internalGetLeaveHistory (req,response,user.emp_id);
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

}

function internalGetLeaveHistory (req,response,empID){
	var callback = function (err,data){
		if (err == null) {
			response.send(JSON.stringify(data));
		}
		else {
			response.status(500).send(error.DatabaseError(err));
		}
	}
	sqlHandle.fetchLeaveHistory(empID,callback);
}


InternalWebService.prototype.cancelLeaveRequest = function cancelLeaveRequest (req,response){
	var accessCallback = function (err, user) {
		if(err == null) {
			var userRole = getUserRole (user.role_id);
			if(userRole == ROLE.SUPERVISOR || userRole == ROLE.MANAGER || userRole == ROLE.EMPLOYEE){
				internalCancelLeaveRequest(req,response,req.body.requestID)
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
}

function internalCancelLeaveRequest (req,response,requestID) {
	var callback = function (err,data){
		if (err == null) {
			//response.send(JSON.stringify(data));
			var successResponse = {success : "Successfully Canceled Leave Request"};
			response.send(successResponse);
		}
		else {
			response.status(500).send(error.DatabaseError(err));
		}
	}

	sqlHandle.cancelLeaveRequest(requestID,callback);
}

InternalWebService.prototype.approveLeaveRequest = function approveLeaveRequest(req,response){

	var accessCallback = function (err, user) {
		if(err == null) {
			var userRole = getUserRole (user.role_id);
			if(userRole == ROLE.SUPERVISOR || userRole == ROLE.MANAGER){
				if(req.body.leaveStatus == "Approve"){
					internalApproveLeave (req,response,req.body.requestID);
				}
				else if(req.body.leaveStatus == "Reject") {
					internalRejectLeave (req,response,req.body.requestID);
				}
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

function internalRejectLeave (req,response,requestID){
	var callback = function (err,data){
			if (err == null) {
				//response.send(JSON.stringify(data));
				var successResponse = {success : "Successfully updated leave request"};
				response.send(successResponse);
			}
			else {
				response.status(500).send(error.DatabaseError(err));
			}
	}

	sqlHandle.rejectLeaveRequest(requestID,callback);
}

function internalApproveLeave (req,response,requestID){
	
	var statusCallback = function (status) {
		if(status){
			//approve
			modifyLeaveState (req,response,requestID);
		}
		else {
			//throw error
			response.status(400).send(error.InputError("Something wrong with the request"));
		}
	}

	checkValidityOfLeaveRequest(requestID,statusCallback);

	
}

//actual approval
function modifyLeaveState (req,response,requestID) {

	var callback = function (err,data){
			if (err == null) {
				//response.send(JSON.stringify(data));
				var successResponse = {success : "Successfully approved leave request"};
				response.send(successResponse);
			}
			else {
				response.status(500).send(error.DatabaseError(err));
			}
	}

	sqlHandle.approveLeaveRequest(requestID,callback);
}

//function that checks if the leave request itself is valid
function checkValidityOfLeaveRequest(requestID,statusCallback){
	var callback = function (err,data){
		if (err == null) {
			//response.send(JSON.stringify(data));
			var leaveRequest = data[0];
			console.log("leaverequest  "+ leaveRequest.emp_id);
			var daysRequested = utils.getWorkingDays (leaveRequest.date_from,leaveRequest.date_to);
			var callback = function (err,data) {
				if(err == null) {
					var daysAvailable = data[0].available;
					console.log("leaves available  "+daysAvailable);
					if(daysRequested > daysAvailable){
						//throw validation error
						console.log("error daysRequested is more than available");
						statusCallback(false);
					}
					else {
						//send success
						statusCallback(true);
					}
				}
				else {
					//something wrong handle this
				}
			} 

			sqlHandle.getAvailableLeaves(leaveRequest.emp_id,callback);
			
		}
		else {
			
		}
	}

	sqlHandle.fetchLeaveRequestFromID(requestID,callback);
}



function getUserRole (roleID) {
	switch (roleID) {
		case 0 :
			return ROLE.ADMIN;
			break;
		case 1 :
			return ROLE.EMPLOYEE;
			break;
		case 2 :
			return ROLE.SUPERVISOR;
			break;
		case 3 :
			return ROLE.MANAGER;
			break;
	}
}


module.exports = InternalWebService;

