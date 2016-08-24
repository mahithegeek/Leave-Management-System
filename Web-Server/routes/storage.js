


var mysql = require('mysql');
var utils = require("./Utilities.js");

var pool;

function Storage() {
     pool      =    mysql.createPool({
      connectionLimit : 100, //important
      host     : 'localhost',
      port : '8889',
      user     : 'root',
      password : 'root',
      database : 'LMS',
      debug    :  false
  });

     utils = new utils ();

}

Storage.prototype.getUserInfo = function getUserInfo (successCallback,errorCallback) {

  pool.getConnection(function(err,connection){
        if (err) {
          res({"code" : 100, "status" : "Error in database connection "});
          return;
        }   

        console.log('connected as id ' + connection.threadId);
        
        connection.query("select availability.available,user.first_name,user.emp_id,user.email from availability INNER JOIN user ON availability.emp_id = user.emp_id",function(err,rows){
            connection.release();
            if(!err) {
                console.log(rows);
                successCallback(rows) ;
            }           
        });

        connection.on('error', function(err) {      
              res({"code" : 100, "status" : "Error in connection database"});
              return;     
        });
  });
};

Storage.prototype.getAvailableLeaves = function getAvailableLeaves (successCallback,errorCallback,EmployeeID) {

    pool.getConnection(function(err,connection){
        if (err) {
          res({"code" : 100, "status" : "Error in database connection "});
          return;
        }   

        console.log('connected as id ' + connection.threadId);
        
        connection.query("select * from availability where emp_id = ?",EmployeeID,function(err,rows){
            connection.release();
            if(!err) {
                successCallback(rows) ;
            }           
        });

        connection.on('error', function(err) {      
              res({"code" : 100, "status" : "Error in connection database"});
              return;     
        });
  });
};

Storage.prototype.insertLeaves = function insertLeaves (successCallback,errorCallback,leaveRequest) {

   var queryString = "INSERT INTO leaves SET date_from = ?, date_to = ?,half_Day = ?,applied_on = ?,status_id = (SELECT id FROM status WHERE status = 'Applied'),emp_id = ?, type_id = ?";
   

        var date = utils.getFormattedDate (new Date());
        var dbRequestObject = {date_from : leaveRequest.fromDate,date_to : leaveRequest.toDate, half_Day : 1,applied_on : date, status_id : 0,type_id : leaveRequest.typeid,emp_id : leaveRequest.emp_id};
        var dataObject = [dbRequestObject.date_from,dbRequestObject.date_to,dbRequestObject.half_Day,dbRequestObject.applied_on,9526,1];

        runSqlQuery(queryString,dataObject,successCallback,errorCallback);

   /*
   pool.getConnection(function(err,connection){
        if (err) {
          res({"code" : 100, "status" : "Error in database connection "});
          return;
        }   


        //console.log('connected as id ' + connection.threadId);
        //(SELECT id FROM status WHERE status = 'Applied')
        //connection.query("INSERT INTO leaves SET date_from = ?,date_to = ?,half_Day = ?,applied_on = ?,status_id = ?,type_id = ?,emp_id = ?",dbRequestObject.date_from,dbRequestObject.date_to,dbRequestObject.half_Day,dbRequestObject.applied_on,1,dbRequestObject.type_id,dbRequestObject.emp_id,function(err,result)

         //frozen query connection.query("INSERT INTO leaves SET date_from = ?, date_to = ?,status_id = ?,emp_id = ?, type_id = ?",[dbRequestObject.date_from,dbRequestObject.date_to,1,9526,1],function(err,result)
        var date = utils.getFormattedDate (new Date());
        var dbRequestObject = {date_from : leaveRequest.fromDate,date_to : leaveRequest.toDate, half_Day : 1,applied_on : date, status_id : 0,type_id : leaveRequest.typeid,emp_id : leaveRequest.emp_id};
        console.log (dbRequestObject);
        
        connection.query("INSERT INTO leaves SET date_from = ?, date_to = ?,half_Day = ?,applied_on = ?,status_id = (SELECT id FROM status WHERE status = 'Applied'),emp_id = ?, type_id = ?",[dbRequestObject.date_from,dbRequestObject.date_to,dbRequestObject.half_Day,dbRequestObject.applied_on,9526,1],function(err,result){
            connection.release();
            if(!err) {
                console.log("success");
                successCallback(result) ;
                
            }
            else{
              console.log (err);
              errorCallback (err);
            }           
        });

        connection.on('error', function(err) {      
              res({"code" : 100, "status" : "Error in connection database"});
              return;     
        });
        */
  };

Storage.prototype.verifyUserExists = function verifyUserExists (userEmail,callBack) {
    var queryString = "SELECT 1 FROM user WHERE auth_email = '"+userEmail+"' ORDER BY auth_email LIMIT 1";

    var verifyUserCallback = function (rows) {
        if(rows.length > 0){
           callBack(true);
        }
        else {
          callBack(false);
        }
    };

    var errorCallback = function (error){
      //nothing to send back 
      console.log("verifyUserExists error"+error);
    }
    runSqlQuery(queryString,userEmail,verifyUserCallback,function(error){});
};


function runSqlQuery (sqlQueryString,sqlDataObject,successCallback,errorCallback) {
  pool.getConnection(function(err,connection){
        if (err) {
          res({"code" : 100, "status" : "Error in database connection "});
          return;
        }   

        connection.query(sqlQueryString,sqlDataObject,function(err,result){
            connection.release();
            if(!err) {
                console.log(result);
                successCallback(result) ;
                
            }
            else{
              console.log (err);
              errorCallback (err);
            }           
        });

        connection.on('error', function(err) {      
              res({"code" : 100, "status" : "Error in connection database"});
              return;     
        });
  });
}

module.exports = Storage;

