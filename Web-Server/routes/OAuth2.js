var XMLHttpRequest = require ("xmlhttprequest").XMLHttpRequest;
var tokenVerifier = require ('google-id-token-verifier');


//empty constructor
function OAuth2 (){


	
}

OAuth2.prototype.verifyTokenID = function (tokenID,sucessCallback,errorCallback) {

	//TODO put more stricter verification and validation
	if(!tokenID){
		errorCallback("Invalid Token ID");
		return;
	}

	//console.log ("token id is"+tokenID);
	validateTokenUsingLib(tokenID,sucessCallback,errorCallback);

};

//if you want to split a token and look at Aud and other details
function splitToken (tokenID) {
	var parts = tokenID.split('.');
	var headerBuf = new Buffer(parts[0],'base64');
	var bodyBuf = new Buffer(parts[1],'base64');
	var header = JSON.parse(headerBuf.toString());
	var body = JSON.parse (bodyBuf.toString());

	console.log ("body is " + JSON.stringify(body));
}

function validateTokenUsingGoogleAPI (tokenID,sucessCallback,errorCallback) {
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
}

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

function validateTokenUsingLib (tokenID,sucessCallback,errorCallback) {
	//hardcoded client ID for now - is it good to take this from client??
	var clientId = '407408718192.apps.googleusercontent.com';

	tokenVerifier.verify (tokenID,clientId,function (error, tokenInfo){
		if(!error){
			console.log ("Successfully validated token" + tokenInfo.email);
			sucessCallback (tokenInfo.email);
			return;
		}
		else {
			console.log ("error is " + error);
			errorCallback(error);
			return;
		}

	});
}




module.exports = OAuth2;