
var store = require("./storage.js");

var appRouter = function(app) {

	app.get("/", function(req, res) {
    res.send("Hello Mahi");
});

	var sqlHandle = new store();

	app.use(function (req,res,next){

		res.setHeader('Access-Control-Allow-Origin', 'http://172.26.34.33:1111','http://localhost:1111');
		//res.setHeader('Access-Control-Allow-Origin', 'http://localhost:1111');
		res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, PATCH, DELETE');
		res.setHeader('Access-Control-Allow-Headers', 'Content-Type,Accept');
		next();
	});

	//API to get users 
 	app.post("/getUsers",function (req, response) {

 		console.log(req.body.username);
 		//To DO just check the credentials and see if this is a legitimate request
 		sqlHandle.getUserInfo(function(data){console.log(JSON.stringify(data)); response.send(JSON.stringify(data));},function(eror){});
 	
	});

 	//API to get available leaves
 	app.post("/getAvailableLeaves",function (req, response) {

 		
 		if(req.body.empid ) {
 			//sqlHandle.getUserInfo(function(data){console.log(JSON.stringify(data)); response.send(JSON.stringify(data));},function(eror){});
 			sqlHandle.getAvailableLeaves(function (data) {console.log(JSON.stringify(data));response.send(JSON.stringify(data));},function(error){},req.body.empid);
 		}
 		else {
 			response.send ("Invalid Employee ID");
 		}
 	
	});

	app.post("/applyLeave",function (req,response){

			if(validateDate(req.body.fromDate) && validateDate(req.body.toDate)) {
				console.log("dates are valid");
				response.send ( "successfully applied");
			}
			else {
				response.send ("Invalid dates");
			}

		
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