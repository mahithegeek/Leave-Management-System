
function ServerError (code,message) {
	
}

ServerError.prototype.UserAccessDeniedError = function () {
	//move error codes to constant
	var error = {code:4000,description:"User has no access to this API"};
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



