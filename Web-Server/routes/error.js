
function ServerError (code,message) {
	
}

ServerError.prototype.UserAccessDeniedError = function () {
	//move error codes to constant
	var error = {code:4000,description:"User has no access to this API"};
	return error;

};

ServerError.prototype.UserNotFoundError = function () {
	var error = {code : 4001, description:"User Not Found"};
	return error;
};

ServerError.prototype.SuperVisorNotFound = function () {
	var error = {code : 4002, description:"SuperVisor To this user doesnot exist"};
	return error;
};

ServerError.prototype.DatabaseError = function (message) {
	var error = {code:4100,description:message};
	return error;
}

ServerError.prototype.InputError = function (message) {
	var error = {code : 4200,description:message};
	return error;
}

module.exports = ServerError;



