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

typealias OIDAuthCallback = (_ idToken:String?,NSError?) -> Void
typealias OIDDataCallback = (_ response:AnyObject?,NSError?) -> Void

class OAuthManager: NSObject, OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    fileprivate var issuer: URL?
    fileprivate var clientID: String?
    fileprivate var redirectURI: URL?
    fileprivate var viewController:UIViewController?
    fileprivate var authorizationErrorCallback:OIDAuthCallback?
    fileprivate var authState:OIDAuthState?
    fileprivate (set) var idToken:String?
    
    fileprivate override init() {
    }
    
    required init(withIssuer issuer:URL, clientID:String, redirecURI:URL, viewController:UIViewController){
        self.issuer = issuer
        self.clientID = clientID
        self.redirectURI = redirecURI
        self.viewController = viewController
        super.init()
        self.loadState()
    }
    
    fileprivate func setAuthorizationState(withState authState:OIDAuthState?){
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
    fileprivate func saveState(){
        if self.authState != nil{
            let archivedAuthState = NSKeyedArchiver.archivedData(withRootObject: self.authState!)
            UserDefaults.standard.set(archivedAuthState, forKey: kAppAuthExampleAuthStateKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    /*! @fn loadState
     @brief Loads the @c OIDAuthState from @c NSUSerDefaults.
     */
    fileprivate func loadState() {
        // loads OIDAuthState from NSUSerDefaults
        let archivedAuthState = UserDefaults.standard.object(forKey: kAppAuthExampleAuthStateKey)
        if archivedAuthState != nil{
            let authState:OIDAuthState? = NSKeyedUnarchiver .unarchiveObject(with: archivedAuthState! as! Data) as? OIDAuthState
            if authState != nil{
                self.setAuthorizationState(withState: authState)
            }
        }
    }
    
    // Callbacks for OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate
    
    func didChange(_ state: OIDAuthState) {
        self.saveState()
    }
    
    func authState(_ state: OIDAuthState, didEncounterAuthorizationError error: Error) {
        self.authorizationErrorCallback!(nil,error as NSError?)
    }
    
    func discoveryService(withCompletion completion:@escaping OIDDiscoveryCallback) {
        OIDAuthorizationService .discoverConfiguration(forIssuer: issuer!) { (oidServiceConfiguration, error) in
            completion(oidServiceConfiguration,error)
        }
    }
    
    func authWithAutoCodeExchange(withCompletion completion:@escaping OIDAuthCallback){
        self.authorizationErrorCallback = completion
        self.discoveryService { (serviceConfig, error) in
            guard serviceConfig != nil else{
                NSLog("Error \(error)")
                self.setAuthorizationState(withState: nil)
                completion(nil,nil)
                return
            }
            
            let request:OIDAuthorizationRequest = OIDAuthorizationRequest.init(configuration: serviceConfig!, clientId: self.clientID!, scopes: [OIDScopeProfile], redirectURL: self.redirectURI!, responseType: OIDResponseTypeCode, additionalParameters: nil)
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            
            appDelegate.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self.viewController!, callback: { (authState, error) in
                if (authState != nil){
                    completion(authState?.lastTokenResponse!.idToken, nil)
                    self.idToken = authState?.lastTokenResponse!.idToken
                    self.setAuthorizationState(withState: authState)
                }
                else{
                    // Log Error
                    NSLog("Error \(error)")
                    completion(nil,error! as NSError?)
                    self.idToken = nil
                }
            })
        }
    }
    
    func requestAccessToken(withCompletion completion:@escaping OIDAuthCallback){
        self.authState?.withFreshTokensPerformAction({ (accessToken, idToken, error) in
            completion(idToken,error as NSError?)
            self.idToken = accessToken
        })
    }
    
    func requestUserinfo(withCompletion completion:@escaping OIDDataCallback) {
        let userInfoEndpoint = authState?.lastAuthorizationResponse.request.configuration.discoveryDocument?.userinfoEndpoint
        if userInfoEndpoint == nil{
            //Userinfo endpoint not declared in discovery document
            completion(nil,nil)
            return
        }
        let currentAccessToken = authState?.lastTokenResponse?.accessToken
        
        authState?.withFreshTokensPerformAction(){
            accessToken,idToken,error in
            if error != nil{
                completion(nil,error as NSError?)
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
            let request = NSMutableURLRequest(url: userInfoEndpoint!)
            let authorizationHeaderValue = "Bearer \(accessToken!)"
            request.addValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
            
//            let configuration = URLSessionConfiguration.default
//            let session = URLSession(configuration: configuration)
            let postDataTask = URLSession.shared.dataTask(with: request as URLRequest) {data,response,error in
                
                DispatchQueue.main.async{
                    guard let httpResponse = response as? HTTPURLResponse else{
                        completion(nil,error as NSError?)
                        return
                    }
                    do{
                        let jsonDictionaryOrArray = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        if httpResponse.statusCode != 200{
                            if httpResponse.statusCode == 401{
                                // "401 Unauthorized" generally indicates there is an issue with the authorization
                                // grant. Puts OIDAuthState into an error state.
                                let oauthError = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0, errorResponse: jsonDictionaryOrArray as? [AnyHashable: Any], underlyingError: error)
                                self.authState?.update(withAuthorizationError: oauthError!)
                                //log error
                                completion(nil,oauthError as NSError?)
                            }
                            else{
                                completion(nil,nil)
                            }
                            return
                        }
                        completion(jsonDictionaryOrArray as AnyObject?,error as NSError?)
                    }
                    catch{
                        completion(nil,nil)
                    }
                }
                
                
            };
            postDataTask.resume();

//            // performs HTTP request
//            let poDataTask = URLSession.shared.dataTask(with: request, completionHandler: {
//                data,response,error in
//                DispatchQueue.main.async{
//                    guard let httpResponse = response as? HTTPURLResponse else{
//                        completion(response: nil,error)
//                        return
//                    }
//                    do{
//                        let jsonDictionaryOrArray = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
//                        if httpResponse.statusCode != 200{
//                            if httpResponse.statusCode == 401{
//                                // "401 Unauthorized" generally indicates there is an issue with the authorization
//                                // grant. Puts OIDAuthState into an error state.
//                                let oauthError = OIDErrorUtilities.resourceServerAuthorizationError(withCode: 0, errorResponse: jsonDictionaryOrArray as? [AnyHashable: Any], underlyingError: error)
//                                self.authState?.update(withAuthorizationError: oauthError!)
//                                //log error
//                                completion(response: nil,oauthError)
//                            }
//                            else{
//                                completion(response: nil,nil)
//                            }
//                            return
//                        }
//                        completion(response: jsonDictionaryOrArray,error)
//                    }
//                    catch{
//                       completion(response: nil,nil)
//                    }
//                }
//            })
//            postDataTask.resume()
        }
    }

        
    
}
