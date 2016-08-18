var http = require ('http');
var express = require ('express');
var bodyParser = require("body-parser");
var app = express();
app.set ('port',process.env.PORT || 9526);

// app.get('/',function (req,res){

// 	res.send ('<html><body><h1>Hello World</h1></body></html>');

// })

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended : true}));



var routes = require("./routes/routes.js")(app);


//create server
http.createServer (app).listen (app.get('port'), function(){

	console.log('Express server listening on port ' + app.get('port'));
});



// //database connection
// connection.connect(function (err) {

// 	if(err) {
// 		console.error ('error connecting : ' + err.stack);
// 		return;
// 	}

// 	console.log('connected as id ' + connection.threadId);
// });


// connection.query('SELECT * from user',function(err,rows,fields) {

// 		connection.end();
// 		if(!err){
// 			console.log('Users are :' , rows);
// 		}
// 		else {
// 			console.log('Error while performing query');
// 		}

// 	});


