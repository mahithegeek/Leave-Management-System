//
//  OAuthManager.swift
//  AuthPodTest
//
//  Created by Ravi on 8/29/16.
//  Copyright © 2016 Ravi. All rights reserved.
//

import Foundation
import AppAuth


/*! @var kAppAuthExampleAuthStateKey
 @brief NSCoding key for the authState property.
 */
let kAppAuthExampleAuthStateKey:String = "authState"

typealias OIDAuthCallback = (idToken:String?,NSError?) -> Void
typealias OIDDataCallback = (response:AnyObject?,NSError?) -> Void

class OAuthManager: NSObject, OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    private var issuer: NSURL?
    private var clientID: String?
    private var redirectURI: NSURL?
    private var viewController:UIViewController?
    private var authorizationErrorCallback:OIDAuthCallback?
    private var authState:OIDAuthState?
    private (set) var idToken:String?
    
    private override init() {
    }
    
    required init(withIssuer issuer:NSURL, clientID:String, redirecURI:NSURL, viewController:UIViewController){
        self.issuer = issuer
        self.clientID = clientID
        self.redirectURI = redirecURI
        self.viewController = viewController
        super.init()
        self.loadState()
    }
    
    private func setAuthorizationState(withState authState:OIDAuthState?){
        if (self.authState == authState) {
            return
        }
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        self.saveState()
    }
    
    /*! @fn saveState
     @brief Saves the @c OIDAuthState to @c NSUSerDefaults.
     */
    private func saveState(){
        if self.authState != nil{
            let archivedAuthState = NSKeyedArchiver.archivedDataWithRootObject(self.authState!)
            NSUserDefaults.standardUserDefaults().setObject(archivedAuthState, forKey: kAppAuthExampleAuthStateKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    /*! @fn loadState
     @brief Loads the @c OIDAuthState from @c NSUSerDefaults.
     */
    private func loadState() {
        // loads OIDAuthState from NSUSerDefaults
        let archivedAuthState = NSUserDefaults.standardUserDefaults().objectForKey(kAppAuthExampleAuthStateKey)
        if archivedAuthState != nil{
            let authState:OIDAuthState? = NSKeyedUnarchiver .unarchiveObjectWithData(archivedAuthState! as! NSData) as? OIDAuthState
            if authState != nil{
                self.setAuthorizationState(withState: authState)
            }
        }
    }
    
    // Callbacks for OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate
    
    func didChangeState(state: OIDAuthState) {
        self.saveState()
    }
    
    func authState(state: OIDAuthState, didEncounterAuthorizationError error: NSError) {
        self.authorizationErrorCallback!(idToken:nil,error)
    }
    
    func discoveryService(withCompletion completion:OIDDiscoveryCallback) {
        OIDAuthorizationService .discoverServiceConfigurationForIssuer(issuer!) { (oidServiceConfiguration, error) in
            completion(oidServiceConfiguration,error)
        }
    }
    
    func authWithAutoCodeExchange(withCompletion completion:OIDAuthCallback){
        self.authorizationErrorCallback = completion
        self.discoveryService { (serviceConfig, error) in
            guard serviceConfig != nil else{
                NSLog("Error \(error)")
                self.setAuthorizationState(withState: nil)
                completion(idToken: nil,nil)
                return
            }
            
            let request:OIDAuthorizationRequest = OIDAuthorizationRequest.init(configuration: serviceConfig!, clientId: self.clientID!, scopes: [OIDScopeProfile], redirectURL: self.redirectURI!, responseType: OIDResponseTypeCode, additionalParameters: nil)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.currentAuthorizationFlow = OIDAuthState.authStateByPresentingAuthorizationRequest(request, presentingViewController: self.viewController!, callback: { (authState, error) in
                if (authState != nil){
                    completion(idToken: authState?.lastTokenResponse!.idToken, nil)
                    self.idToken = authState?.lastTokenResponse!.idToken
                    self.setAuthorizationState(withState: authState)
                }
                else{
                    // Log Error
                    NSLog("Error \(error)")
                    completion(idToken: nil,error!)
                    self.idToken = nil
                }
            })
        }
    }
    
    func requestAccessToken(withCompletion completion:OIDAuthCallback){
        self.authState?.withFreshTokensPerformAction({ (accessToken, idToken, error) in
            completion(idToken: idToken,error)
            self.idToken = accessToken
        })
    }
    
    func requestUserinfo(withCompletion completion:OIDDataCallback) {
        let userInfoEndpoint = authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint
        if userInfoEndpoint == nil{
            //Userinfo endpoint not declared in discovery document
            completion(response: nil,nil)
            return
        }
        let currentAccessToken = authState?.lastTokenResponse?.accessToken
        
        authState?.withFreshTokensPerformAction(){
            accessToken,idToken,error in
            if error != nil{
                completion(response: nil,error)
                return
            }
            
            // log whether a token refresh occurred
            if currentAccessToken != accessToken{
               // print("Access token was refreshed automatically (\(currentAccessToken!) to \(accessToken!)")
            }
            else{
               // print("Access token was fresh and not updated [\(accessToken!)]")
            }
            
            // creates request to the userinfo endpoint, with access token in the Authorization header
            let request = NSMutableURLRequest(URL: userInfoEndpoint!)
            let authorizationHeaderValue = "Bearer \(accessToken!)"
            request.addValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
            
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: configuration)
            
            // performs HTTP request
            let postDataTask = session.dataTaskWithRequest(request){
                data,response,error in
                dispatch_async(dispatch_get_main_queue()){
                    guard let httpResponse = response as? NSHTTPURLResponse else{
                        completion(response: nil,error)
                        return
                    }
                    do{
                        let jsonDictionaryOrArray = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                        if httpResponse.statusCode != 200{
                            if httpResponse.statusCode == 401{
                                // "401 Unauthorized" generally indicates there is an issue with the authorization
                                // grant. Puts OIDAuthState into an error state.
                                let oauthError = OIDErrorUtilities.resourceServerAuthorizationErrorWithCode(0, errorResponse: jsonDictionaryOrArray as? [NSObject : AnyObject], underlyingError: error)
                                self.authState?.updateWithAuthorizationError(oauthError!)
                                //log error
                                completion(response: nil,oauthError)
                            }
                            else{
                                completion(response: nil,nil)
                            }
                            return
                        }
                        completion(response: jsonDictionaryOrArray,error)
                    }
                    catch{
                       completion(response: nil,nil)
                    }
                }
            }
            postDataTask.resume()
        }
    }

        
    
}