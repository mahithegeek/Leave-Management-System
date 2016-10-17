
var internalWebService = require ("./InternalWebService.js");

var appRouter = function(app) {

	var internalServices = new internalWebService(); 
	app.use(function (req,res,next){

		res.setHeader('Access-Control-Allow-Origin', 'http://172.26.34.33:1111');
		res.setHeader('Access-Control-Allow-Origin', 'http://localhost:1111');
		res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
		res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Accept');
		next();
	});

	//API to get users 
 	app.post("/users",function (req, response) {
 		internalServices.getUsers(req,response);
 	
	});

 	//API to get available leaves
 	app.post("/availableLeaves",function (req, response) {

 		internalServices.getAvailableLeaves(req,response);
 	
	});

	app.post("/leave",function (req,response){

		internalServices.applyLeave (req,response);
	});

	app.post("/login",function (req,response) {

		internalServices.login (req,response);
	});

	app.post("/leaveRequests",function (req,response){
		internalServices.getLeaveRequests (req,response);
	});


	app.post("/approveLeave",function (req,response){
		internalServices.approveLeaveRequest (req, response);

	});

	app.post("/leaveHistory",function (req,response){
		internalServices.getLeaveHistory (req,response);
	});

	
 
}
 
module.exports = appRouter;