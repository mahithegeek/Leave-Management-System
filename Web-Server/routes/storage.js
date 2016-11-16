
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
          callback(getConnectionError(),null);
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
              console.log(err);
              callback(getDBRunTimeError(),null);
              return;
            }         
        });

        connection.on('error', function(err) {      
              //res({"code" : 100, "status" : "Error in connection database"});
              callback(getConnectionError(),null);
              return;     
        });
  });
};

Storage.prototype.getAvailableLeaves = function getAvailableLeaves (EmployeeID,callback) {

    pool.getConnection(function(err,connection){
        if (err) {
          callback(getConnectionError(),null);
          return;
        }   
        
        console.log("emp id is" + EmployeeID);
        connection.query("select * from availability where emp_id = ?",EmployeeID,function(err,rows){
            connection.release();
            if(!err) {
                console.log (rows);
                callback(null,rows) ;
                return;
            }          
            else {
              callback(getDBRunTimeError(),null);
              return;
            } 
        });

        connection.on('error', function(err) {      
              callback(getConnectionError(),null);
              return;     
        });
  });
};

Storage.prototype.insertLeaves = function insertLeaves (leaveRequest,callback) {

   var queryString = "INSERT INTO leaves SET date_from = ?, date_to = ?,half_Day = ?,applied_on = ?,status_id = (SELECT id FROM status WHERE status = 'Applied'),emp_id = ?, type_id = ?,days = ?,reason = ?";
  
   var dataObject = [leaveRequest.date_from,leaveRequest.date_to,leaveRequest.half_Day,leaveRequest.applied_on,leaveRequest.emp_id,1,leaveRequest.days,leaveRequest.reason];
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
          callback(getDBRunTimeError(),null);
        }
        
    };
    runSqlQuery(queryString,userEmail,verifyUserCallback);
};

Storage.prototype.fetchUser = function fetchUser(userEmail,callback) {
    var queryString = "SELECT user.* ,role.role FROM user INNER JOIN role ON role.id = user.role_id WHERE user.auth_email = '" + userEmail + "'";
    runSqlQuery (queryString,null,callback);
};

Storage.prototype.fetchSuperVisor = function fetchSuperVisor (supervisorID,callback) {
    var queryString = "SELECT * FROM user WHERE emp_id = '"+supervisorID+ "'";
    runSqlQuery (queryString,null,callback);
};

Storage.prototype.fetchLeaveRequests = function (empID, callback) {
  var queryString = "SELECT user.*,leaves.*,DATE_FORMAT(leaves.date_from,'%Y-%m-%d') as date_from,DATE_FORMAT(leaves.date_to,'%Y-%m-%d') as date_to,DATE_FORMAT(leaves.applied_on,'%Y-%m-%d') as applied_on ,status.status FROM user INNER JOIN leaves ON leaves.emp_id = user.emp_id INNER JOIN status ON status.id = leaves.status_id WHERE user.supervisor = '"+  empID + "'";
  runSqlQuery (queryString,null,callback); 
};

Storage.prototype.approveLeaveRequest = function (requestID,callback){
  console.log("approveLeaveRequest request id is  "+ requestID);
  var queryString = "UPDATE leaves SET status_id = 2 WHERE id = '" + requestID + "' AND status_id = 1";
  runSqlQuery (queryString,null,callback); 
};

Storage.prototype.rejectLeaveRequest = function (requestID,callback) {
  console.log("rejectLeaveRequest request id is  "+ requestID);
  var queryString = "UPDATE leaves SET status_id = 3 WHERE id = '" + requestID + "' AND status_id = 1 ";
  runSqlQuery (queryString,null,callback);
};

Storage.prototype.cancelLeaveRequest = function (requestID,callback) {
  console.log("cancelLeaveRequest");
  var queryString = "UPDATE leaves SET status_id = 4 WHERE id = '" + requestID + "' AND status_id = 1 OR status_id = 2 ";
  runSqlQuery (queryString,null,callback);
};

Storage.prototype.fetchLeaveHistory = function (empID,callback) {
  console.log("emp id is  "+ empID);
  var queryString = "SELECT leaves.* ,status.status,DATE_FORMAT(leaves.date_from,'%Y-%m-%d') as date_from,DATE_FORMAT(leaves.date_to,'%Y-%m-%d') as date_to,DATE_FORMAT(leaves.applied_on,'%Y-%m-%d') as applied_on FROM leaves INNER JOIN status ON status.id = leaves.status_id  WHERE emp_id = '" + empID + "'";
  runSqlQuery (queryString,null,callback);
};

Storage.prototype.fetchLeaveRequestFromID = function (requestID,callback){
  var queryString = "SELECT  leaves.*, DATE_FORMAT(leaves.date_from,'%Y-%m-%d') as date_from,DATE_FORMAT(leaves.date_to,'%Y-%m-%d') as date_to,DATE_FORMAT(leaves.applied_on,'%Y-%m-%d') as applied_on FROM leaves WHERE id = '" + requestID + "'";
  runSqlQuery(queryString,null,callback);
};


function getConnectionError () {
  var conError = "Error in Database connection";
  return conError;
}

function getDBRunTimeError () {
  return "Error getting data";
}

function runSqlQuery (sqlQueryString,sqlDataObject,callback) {
  pool.getConnection(function(err,connection){
        //TODO - throw proper error
        if (err) {
          callback(getConnectionError(),null);
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
              callback (getDBRunTimeError(),null);
              return;
            }           
        });

        connection.on('error', function(err) {      
              callback(getConnectionError(),null);
              return;     
        });
  });
}

module.exports = Storage;

