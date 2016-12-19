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
		if(err == null ) {
			var userData = {firstName : user.firstName, lastName: user.lastName,email : user.email, empID : user.emp_id.toString(), role : user.role,supervisorID : user.supervisor_id.toString(),supervisor:""};
			getSupervisorDetails (userData,response);
			
		}
		else {
			response.status(500).send(error.DatabaseError(err));
		}
	};

	var tokenID = req.body.tokenID;
	//console.log(req.body.tokenID);
	if(utils.validateInputParameters(tokenID)){
		access.determineUser (tokenID, accessCallback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}
	
};

function getSupervisorDetails(user,response) {
	var callback = function (err,data) {
		if(err == null){
			if(data.length > 0){
				var supervisorDetails = {firstName : data[0].first_name,lastName : data[0].last_name,email : data[0].email};
				user.supervisor = supervisorDetails;
				delete user.supervisorID;
				//console.log("user details are  " + JSON.stringify(user));
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

	if(utils.validateInputParameters(user.supervisorID)){
		sqlHandle.fetchSuperVisor(user.supervisorID,callback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}

	
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

	var tokenID = req.body.tokenID;
	//console.log(req.body.tokenID);
	if(utils.validateInputParameters(tokenID)){
		access.determineUser (tokenID, accessCallback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}
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

	var tokenID = req.body.tokenID;
	//console.log(req.body.tokenID);
	if(utils.validateInputParameters(tokenID)){
		access.determineUser (tokenID, accessCallback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}
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
	
	var tokenID = req.body.tokenID;
	if(utils.validateInputParameters(tokenID)){
		access.determineUser (tokenID, accessCallback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}
};

function internalApplyLeave (req,response,leaveRequestReceived,user) {
	
	var leaveAvailabilitycallback = function (err,data){
		if (err == null) {
			console.log("successfully retrieved leaves");
			if(data.length > 0){
				console.log ("checking leaves");
				var leaveAvailability = data[0];
				console.log("leaves from dB " + JSON.stringify(leaveAvailability));
				if(checkLeavesType(leaveRequestReceived,leaveAvailability)){
					insertLeaves (leaveRequestReceived,req,response);
				}
				else {
					response.status(500).send(error.LeaveAvailabilityError("Leaves of type not available"));
				}
				
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

	if(utils.validateInputParameters(leaveRequestReceived) && utils.validateInputParameters(user)){
		leaveRequestReceived = constructLeaveRequest (leaveRequestReceived,user);
		console.log("received request is " + JSON.stringify(leaveRequestReceived));
		checkLeaveAvailability (leaveRequestReceived,user,leaveAvailabilitycallback);
	}
	else {
		response.status(500).send (error.InputValidationError());
	}
}

function checkLeavesType (leaveRequestReceived,dbRecord) {
	if(leaveRequestReceived.type_id == 1) {
		console.log("leave type received is casual");
		if(leaveRequestReceived.days > dbRecord.casual && leaveRequestReceived.days > dbRecord.carry_forward){
			console.log("No Leaves for the user of this type");
			return false;
		}
		else {
			return true;
		}
	}
	else if(leaveRequestReceived.type_id > 1 && leaveRequestReceived.type_id < 10 ) {
		return true;
	}

	return false;
}

function checkLeaveAvailability (leaveRequestReceived,user,callback) {
	sqlHandle.getAvailableLeaves(user.emp_id,callback);
}

function insertLeaves (leaveRequestReceived,req,response) {
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
		//var leave = constructLeaveRequest(leaveRequestReceived,user);
		console.log("leave received is   "+ JSON.stringify(leaveRequestReceived));
		sqlHandle.insertLeaves (leaveRequestReceived,callback);
		
	}
	else {
		response.status(400).send (error.InputError("Invalid Dates"));
	}
}



function constructLeaveRequest (leaveRequestReceived,user) {
	var date = utils.getFormattedDate (new Date());
	var numberOfDays = utils.getWorkingDays(leaveRequestReceived.fromDate,leaveRequestReceived.toDate);
	console.log("type id  "+ leaveRequestReceived.leaveType);
	leaveRequestReceived.typeid = getLeaveTypeIDFromLeave (leaveRequestReceived.leaveType);

    var dbRequestObject = {date_from : leaveRequestReceived.fromDate,date_to : leaveRequestReceived.toDate, half_Day : leaveRequestReceived.isHalfDay,applied_on : date, status_id : 0,type_id : leaveRequestReceived.typeid,emp_id : user.emp_id,days : numberOfDays,reason : leaveRequestReceived.reason};
    console.log(numberOfDays);
    return dbRequestObject;
}

function getLeaveTypeIDFromLeave (leaveType) {
	switch(leaveType) {
		case 'vacation':
			return 1;
		case 'maternity':
			return 2;
		case 'paternity':
			return 3;
		case 'bereavement':
			return 4;
		case 'loss of pay':
			return 5;
		case 'comp-off':
			return 6;
		case 'work from home':
			return 7;
		case 'forgot id':
			return 8;
		default :
			return 10;
	}
}

function getLeaveFromType (leaveID){
	switch(leaveID) {
		case 1 :
			return 'vacation';
		case 2 :
			return 'maternity';
		case 3 :
			return 'paternity';
		case 4 :
			return 'bereavement';
		case 5 :
			return 'loss of pay';
		case 6 :
			return 'comp-off';
		case 7:
			return 'work from home';
		case 8:
			return 'forgot id';
		default:
			return 'unknown';
	}
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
	
	var tokenID = req.body.tokenID;
	if(utils.validateInputParameters(tokenID)){
		access.determineUser (tokenID, accessCallback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}
};

function internalGetLeaveRequests (req,response,empID) {
	console.log("internalGetLeaveRequests and emp id is  "+empID);
	var callback = function (err,data){
			if (err == null) {
				//response.send(JSON.stringify(data));
				var requests = formLeaveRequestResponse(data);
				response.send({leaveRequests:requests});
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
		//var type = getLeaveFromType(dbResult[i].type_id);
		
		//var leaveRequest = {id:dbResult[i].id,firstName:dbResult[i].first_name,lastName:dbResult[i].last_name,email:dbResult[i].email,fromDate:dbResult[i].date_from,toDate:dbResult[i].date_to,half_Day:dbResult[i].half_Day,appliedOn:dbResult[i].applied_on,status:dbResult[i].status,leaveType:type,reason:dbResult[i].reason};
		var leaveRequest = convertDBResultToJSON (dbResult[i]);
		console.log("leave request is   "+ leaveRequest);
		leaveRequestResponse.push(leaveRequest);

	}
	
	return leaveRequestResponse;
}

function convertDBResultToJSON (dbResult) {
	var type = getLeaveFromType(dbResult.type_id);
	console.log ("type is " + type);
	var leaveRequest = {id:dbResult.id,firstName:dbResult.first_name,lastName:dbResult.last_name,email:dbResult.email,fromDate:dbResult.date_from,toDate:dbResult.date_to,half_Day:dbResult.half_Day,appliedOn:dbResult.applied_on,status:dbResult.status,leaveType:type,reason:dbResult.reason};
	return leaveRequest;
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
	
	var tokenID = req.body.tokenID;
	if(utils.validateInputParameters(tokenID)){
		access.determineUser (tokenID, accessCallback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}

}

function internalGetLeaveHistory (req,response,empID){
	var callback = function (err,data){
		if (err == null) {
			//response.send(JSON.stringify(data));
			var requests = formLeaveRequestResponse(data);
			response.send({leaveHistory:requests});
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
	var tokenID = req.body.tokenID;
	if(utils.validateInputParameters(tokenID)){
		access.determineUser (tokenID, accessCallback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}
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

	if(utils.validateInputParameters (requestID)) {
		sqlHandle.cancelLeaveRequest(requestID,callback);
	}
	else {
		response.status(500).send (error.InputValidationError());
	}
	
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

	var tokenID = req.body.tokenID;
	if(utils.validateInputParameters(tokenID)){
		access.determineUser (tokenID, accessCallback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}
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

	if(utils.validateInputParameters(requestID)){
		sqlHandle.rejectLeaveRequest(requestID,callback);
	}
	else {
		response.status(500).send(error.InputValidationError());
	}
	
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

	if(utils.validateInputParameters(requestID)){
		checkValidityOfLeaveRequest(requestID,statusCallback);
	}
	else {
		response.status(500).send (error.InputValidationError());
	}

	
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

