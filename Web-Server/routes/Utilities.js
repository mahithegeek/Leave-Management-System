function Utilities () {
	

}

Utilities.prototype.validateDate = function validateDate (date) {

//console.log("received date" + date);
	var tempDate = new Date (date);
	//console.log(tempDate);
	if(tempDate < new Date()) {
		return 0;
	}

	return 1;
};

module.exports = Utilities;