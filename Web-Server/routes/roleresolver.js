
var sql = require("./storage.js");
var sqlHandle;

function roleresolver () {
	sqlHandle = new sql();
}


roleresolver.prototype.fetchRole = function fetchRole (email,callback) {
	var callback = function (err,data){
		if(err == null && data){
			if(data.length > 0) {
				callback(null,data.role_id);
			}
		}
		else {
			callback(err,null);
		}
	};
	sqlHandle.fetchUser (email,callback);
};

module.exports = roleresolver;

