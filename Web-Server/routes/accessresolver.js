
var sql = require("./storage.js");
var authentication = require("./OAuth2.js");
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
				console.log("roleresolver" + "data parsed is" + parsedData);
				callback(null,data[0]);
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
	var tempContext = this;
	var tokenCallback = function (err,email){
			if(err == null){
				var userCallback = function (err,user){
				if(err == null){
					callback (null,user);
				}
				else {
					callback(err,null);
				}
				
			 };
				
				tempContext.fetchUser (email, userCallback);
			}
			else {
				console.log (err);
				callback(err,null);
			}
			
		};
	auth.verifyTokenID (tokenID,tokenCallback);
};

module.exports = accessresolver;

