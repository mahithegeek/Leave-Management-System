
var mysql = require('mysql');
var utilities = require("./Utilities.js");

var pool,utils;

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

    utils = new utilities();

}

Storage.prototype.getUserInfo = function getUserInfo (supervisorID,callback) {

  pool.getConnection(function(err,connection){
        if (err) {
          res({"code" : 100, "status" : "Error in database connection "});
          return;
        }   
        connection.query("SELECT availability.available,user.first_name,user.emp_id,user.email from availability INNER JOIN user ON availability.emp_id = user.emp_id WHERE user.supervisor = ?",supervisorID,function(err,rows){
            connection.release();
            if(!err) {
                console.log(rows);
                callback(null,rows) ;
                return;
            }  
            else {
              console.log("error");
              callback(err,null);
              return;
            }         
        });

        connection.on('error', function(err) {      
              res({"code" : 100, "status" : "Error in connection database"});
              return;     
        });
  });
};

Storage.prototype.getAvailableLeaves = function getAvailableLeaves (EmployeeID,callback) {

    pool.getConnection(function(err,connection){
        if (err) {
          res({"code" : 100, "status" : "Error in database connection "});
          return;
        }   
        
        connection.query("select * from availability where emp_id = ?",EmployeeID,function(err,rows){
            connection.release();
            if(!err) {
                callback(null,rows) ;
                return;
            }          
            else {
              callback(err,null);
              return;
            } 
        });

        connection.on('error', function(err) {      
              res({"code" : 100, "status" : "Error in connection database"});
              return;     
        });
  });
};

Storage.prototype.insertLeaves = function insertLeaves (leaveRequest,callback) {

   var queryString = "INSERT INTO leaves SET date_from = ?, date_to = ?,half_Day = ?,applied_on = ?,status_id = (SELECT id FROM status WHERE status = 'Applied'),emp_id = ?, type_id = ?";
   

        var date = utils.getFormattedDate (new Date());
        var dbRequestObject = {date_from : leaveRequest.fromDate,date_to : leaveRequest.toDate, half_Day : 1,applied_on : date, status_id : 0,type_id : leaveRequest.typeid,emp_id : leaveRequest.emp_id};
        var dataObject = [dbRequestObject.date_from,dbRequestObject.date_to,dbRequestObject.half_Day,dbRequestObject.applied_on,9526,1];

        runSqlQuery(queryString,dataObject,callback);
  };

Storage.prototype.verifyUserExists = function verifyUserExists (userEmail,callback) {
    var queryString = "SELECT 1 FROM user WHERE auth_email = '"+userEmail+"' ORDER BY auth_email LIMIT 1";

    var verifyUserCallback = function (err,rows) {
        if(err == null){
            if(rows.length > 0){
           callback(null,true);
          }
          else {
            callback(null,false);
          }
        }
        else {
          callback(err,null);
        }
        
    };
    runSqlQuery(queryString,userEmail,verifyUserCallback);
};

Storage.prototype.fetchUser = function fetchUser(userEmail,callback) {
    var queryString = "SELECT user.* ,role.role FROM user INNER JOIN role ON role.id = user.role_id WHERE user.auth_email = '" + userEmail + "'";
    runSqlQuery (queryString,null,callback);
};


function runSqlQuery (sqlQueryString,sqlDataObject,callback) {
  pool.getConnection(function(err,connection){
        //TODO - throw proper error
        if (err) {
          res({"code" : 100, "status" : "Error in database connection "});
          return;
        }   

        connection.query(sqlQueryString,sqlDataObject,function(err,result){
            connection.release();
            if(!err) {
                console.log(result);
                callback(null,result) ;
                return;
                
            }
            else{
              console.log (err);
              callback (err,null);
              return;
            }           
        });

        connection.on('error', function(err) {      
              res({"code" : 100, "status" : "Error in connection database"});
              return;     
        });
  });
}

module.exports = Storage;

