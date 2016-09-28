function Utilities () {
	

}

Utilities.prototype.validateDate = function validateDate (date) {

//console.log("received date" + date);
	var tempDate = new Date (date);
	tempDate.setHours(0,0,0,0);
	var currentDate = new Date();
	currentDate.setHours(0,0,0,0);
	//console.log(tempDate);
	if(tempDate < currentDate) {
		return 0;
	}

	return 1;
};

Utilities.prototype.getFormattedDate = function getFormattedDate(date) {
	var curr_date = date.getDate();
	var curr_month = date.getMonth()+1;
	var curr_year = date.getFullYear();
	return curr_year + "-" + (curr_month<10 ? '0':'')+curr_month + "-" + (curr_date < 10 ? '0':'')+ curr_date;

};

module.exports = Utilities;