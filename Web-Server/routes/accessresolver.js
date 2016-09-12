
var sql = require("./storage.js");
var authentication = require("./OAuth2.js");
var User = require("./User.js");
var sqlHandle,auth;

function accessresolver () {
	sqlHandle = new sql();
	auth = new authentication ();
}


accessresolver.prototype.fetchUser = function fetchUser (email,callback) {
	console.log ("roleresolver : " + email);
	var fetchUserCallback = function (err,data){
		if(err == null && data){
			if(data.length > 0) {
				var parsedData = JSON.stringify(data);
				console.log("roleresolver   " + "data parsed is" + parsedData);
				callback(null,createUser(data[0]));
				return;
			}
		}
		else {
			callback(err,null);
			return;
		}
	};
	sqlHandle.fetchUser (email,fetchUserCallback);
};

accessresolver.prototype.determineUser = function determineUserAccess (tokenID,callback) {
	console.log("token ID is " + tokenID);
	var tempContext = this;
	var tokenCallback = function (err,email){
			if(err == null){
				var userCallback = function (err,user){
				if(err == null){
					callback (null,user);
					return;
				}
				else {
					callback(err,null);
					return;
				}
				
			 };
				
				tempContext.fetchUser (email, userCallback);
			}
			else {
				console.log (err);
				callback(err,null);
				return;
			}
			
		};
	auth.verifyTokenID (tokenID,tokenCallback);
};

function createUser (sqlUser) {
	user = new User (sqlUser.first_name,sqlUser.last_name,sqlUser.email,sqlUser.role,sqlUser.emp_id);
	return user;
}

module.exports = accessresolver;

