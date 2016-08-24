var XMLHttpRequest = require ("xmlhttprequest").XMLHttpRequest;


//empty constructor
function OAuth2 (){


	
}

OAuth2.prototype.verifyTokenID = function (tokenID,sucessCallback,errorCallback) {

	//TODO put more stricter verification and validation
	if(!tokenID){
		errorCallback("Invalid Token ID");
		return;
	}

	console.log ("token id is"+tokenID);
	var getRequest = new XMLHttpRequest();
	//var url = "https://www.googleapis.com/oauth2/v1/tokeninfo?id_token=" + tokenID;
	//this url seems to be different from Google docs but it is working
	var url = "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token="+tokenID;
	getRequest.open ("GET",url,true);

	getRequest.onload = function () {
		if(getRequest.status == 200) {
			if(validateGoogleAuthResponse (getRequest.responseText)) {
				sucessCallback("Success");
				return;
			}
		}
		else {
			errorCallback("Error Logging in");
			return;
		}
	}
	getRequest.send();

};

function validateGoogleAuthResponse (response) {

	console.log (response);
	//build more complex validation logic
	if(response.expires_in > 10 && response.verified_email == true) {
		console.log("valid id");
		return true;
	}
	else{
		console.log("invalid  id");
		return false;
	}
}




module.exports = OAuth2;