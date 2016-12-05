var XMLHttpRequest = require ("xmlhttprequest").XMLHttpRequest;
var tokenVerifier = require ('google-id-token-verifier');

var audience;

//empty constructor
function OAuth2 (){


	
}

OAuth2.prototype.verifyTokenID = function (tokenID,callback) {

	//TODO put more stricter verification and validation
	if(!tokenID || typeof tokenID === 'undefined'){
		//console.log("token ID is " + tokenID);
		callback("Invalid Token ID",null);
		return;
	}

	//console.log ("token id is"+tokenID);
	
	validateTokenUsingLib(tokenID,callback);

};

//if you want to split a token and look at Aud and other details
function getAudFromToken (tokenID) {
	var parts = tokenID.split('.');
	var headerBuf = new Buffer(parts[0],'base64');
	var bodyBuf = new Buffer(parts[1],'base64');
	var header = JSON.parse(headerBuf.toString());
	var body = JSON.parse (bodyBuf.toString());

	//console.log ("body is " + JSON.stringify(body));

	return body.aud;
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

function validateTokenUsingLib (tokenID,callback) {
	//hardcoded client ID for now - is it good to take this from client??
	//var clientId = '407408718192.apps.googleusercontent.com';
	audience = getAudFromToken(tokenID);
	var clientId = getMatchingClientAudience (audience);

	tokenVerifier.verify (tokenID,clientId,function (error, tokenInfo){
		if(!error){
			console.log ("Successfully validated token" + tokenInfo.email);
			callback (null,tokenInfo.email);
			return;
		}
		else {
			console.log ("validateTokenUsingLib error :  " + error.message);
			callback(error.message,null);
			return;
		}

	});
}

function getMatchingClientAudience (audience) {
	var iOSClientID = '890980614355-irpa0ap8n2phdq3fbop1382n2dufdep7.apps.googleusercontent.com'; //- iOS client
	var webClientID = '890980614355-4l2uen2k564afacknt15nigdkst1ta08.apps.googleusercontent.com'; // - web client
	var androidClientID = '890980614355-l8lm8hhjk7tidsvimq5meusk3q9t002n.apps.googleusercontent.com'; //Android client

	if(audience == iOSClientID){
		return iOSClientID;
	}
	else if(audience == webClientID) {
		return webClientID;
	}
	else if(audience == androidClientID) {
		return androidClientID;
	}

}


module.exports = OAuth2;