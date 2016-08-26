
var sql = require("./storage.js");
var authentication = require("./OAuth2.js");
var sqlHandle,auth;

function accessresolver () {
	sqlHandle = new sql();
	auth = new authentication ();
}


accessresolver.prototype.fetchRole = function fetchRole (email,callback) {
	console.log ("roleresolver : " + email);
	var fetchUserCallback = function (err,data){
		if(err == null && data){
			if(data.length > 0) {
				var parsedData = JSON.stringify(data);
				console.log("roleresolver" + "data parsed is" + parsedData);
				callback(null,data[0].role_id);
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

accessresolver.prototype.determineUserAccess = function determineUserAccess (tokenID,callback) {
	var temp = this;
	var tokenCallback = function (err,email){
			if(err == null){
				var roleCallback = function (err,role){
				if(err == null){
					callback (null,parseInt(role));
				}
				else {
					callback(err,null);
				}
				
			 };
				
				temp.fetchRole (email, roleCallback);
			}
			else {
				console.log (err);
				callback(err,null);
			}
			
		};
	auth.verifyTokenID (tokenID,tokenCallback);
};

module.exports = accessresolver;

