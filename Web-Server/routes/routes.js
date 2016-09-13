
var internalWebService = require ("./InternalWebService.js");

var appRouter = function(app) {

	var internalServices = new internalWebService(); 
	app.use(function (req,res,next){

		res.setHeader('Access-Control-Allow-Origin', 'http://172.26.34.33:1111','http://localhost:1111');
		//res.setHeader('Access-Control-Allow-Origin', 'http://localhost:1111');
		res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
		res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Accept');
		next();
	});

	//API to get users 
 	app.post("/getUsers",function (req, response) {
 		internalServices.getUsers(req,response);
 	
	});

 	//API to get available leaves
 	app.post("/getAvailableLeaves",function (req, response) {

 		internalServices.getAvailableLeaves(req,response);
 	
	});

	app.post("/applyLeave",function (req,response){

		internalServices.applyLeave (req,response);
	});

	app.post("/login",function (req,response) {

		internalServices.login (req,response);
	});

	app.post("/getLeaveRequests",function (req,response){
		internalServices.getLeaveRequests (req,response);
	});

	function validateDate (date) {
		//console.log("received date" + date);
		var tempDate = new Date (date);
		//console.log(tempDate);
		if(tempDate < new Date()) {
			return 0;
		}

		return 1;
	} 
 
}
 
module.exports = appRouter;