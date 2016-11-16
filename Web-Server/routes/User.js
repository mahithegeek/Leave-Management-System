

function User (firstName,lastName,email,role,role_id,empID,superVisorID) {

	this.firstName = firstName;
	this.lastName = lastName;
	this.email = email;
	this.role = role;
	this.role_id = role_id;
	this.emp_id = empID;
	this.supervisor_id = superVisorID;
	this.supervisorName = " ";

}



module.exports = User;