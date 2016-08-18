


var mysql = require('mysql');

var pool;

function Storage() {
     pool      =    mysql.createPool({
      connectionLimit : 100, //important
      host     : 'localhost', // use your own
      port : 'XXXX',          //use your own port
      user     : 'username',  //use your own
      password : 'password',  //use your own
      database : 'Your DB',
      debug    :  false
  });

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

   pool.getConnection(function(err,connection){
        if (err) {
          res({"code" : 100, "status" : "Error in database connection "});
          return;
        }   

        //console.log('connected as id ' + connection.threadId);
        
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

module.exports = Storage;

