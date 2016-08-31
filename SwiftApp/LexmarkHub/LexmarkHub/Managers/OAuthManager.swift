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

typealias OIDAuthCallback = (token:String?,NSError?) -> Void

class OAuthManager: NSObject, OIDAuthStateChangeDelegate, OIDAuthStateErrorDelegate {
    
    private var issuer: NSURL?
    private var clientID: String?
    private var redirectURI: NSURL?
    private var viewController:UIViewController?
    private var authorizationErrorCallback:OIDAuthCallback?
    private var authState:OIDAuthState?
    
    private override init() {
    }
    
    required init(withIssuer issuer:NSURL, clientID:String, redirecURI:NSURL, viewController:UIViewController){
        self.issuer = issuer
        self.clientID = clientID
        self.redirectURI = redirecURI
        self.viewController = viewController
        super.init()
    }
    
    func setAuthorizationState(withState authState:OIDAuthState?){
        if (self.authState == authState) {
            return
        }
        self.authState = authState
        self.authState?.stateChangeDelegate = self
        self.saveState()
    }
    
    func didChangeState(state: OIDAuthState) {
        self.saveState()
    }
    
    func authState(state: OIDAuthState, didEncounterAuthorizationError error: NSError) {
        self.authorizationErrorCallback!(token:nil,error)
    }
    
    func discoveryService(withCompletion completion:OIDDiscoveryCallback) {
        OIDAuthorizationService .discoverServiceConfigurationForIssuer(issuer!) { (oidServiceConfiguration, error) in
            completion(oidServiceConfiguration,error)
        }
    }
    
    /*! @fn saveState
     @brief Saves the @c OIDAuthState to @c NSUSerDefaults.
     */
    func saveState(){
        let archivedAuthState = NSKeyedArchiver.archivedDataWithRootObject(self.authState!)
        NSUserDefaults.standardUserDefaults().setObject(archivedAuthState, forKey: kAppAuthExampleAuthStateKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    /*! @fn loadState
     @brief Loads the @c OIDAuthState from @c NSUSerDefaults.
     */
    func loadState() {
    // loads OIDAuthState from NSUSerDefaults
        let archivedAuthState = NSUserDefaults.standardUserDefaults().objectForKey(kAppAuthExampleAuthStateKey)
        let authState:OIDAuthState = NSKeyedUnarchiver .unarchiveObjectWithData(archivedAuthState! as! NSData) as! OIDAuthState
        self.setAuthorizationState(withState: authState)
    }
    
    func authWithAutoCodeExchange(withCompletion completion:OIDAuthCallback){
        self.authorizationErrorCallback = completion
        self.discoveryService { (serviceConfig, error) in
            guard serviceConfig != nil else{
                NSLog("Error \(error)")
                self.setAuthorizationState(withState: nil)
                completion(token: nil,nil)
                return
            }
            
            let request:OIDAuthorizationRequest = OIDAuthorizationRequest.init(configuration: serviceConfig!, clientId: self.clientID!, scopes: [OIDScopeProfile], redirectURL: self.redirectURI!, responseType: OIDResponseTypeCode, additionalParameters: nil)
            let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.currentAuthorizationFlow = OIDAuthState.authStateByPresentingAuthorizationRequest(request, presentingViewController: self.viewController!, callback: { (authState, error) in
                if (authState != nil){
                    completion(token: authState?.lastTokenResponse!.accessToken, nil)
                    self.setAuthorizationState(withState: authState)
                }
                else{
                    // Log Error
                    NSLog("Error \(error)")
                    completion(token: nil,error!)
                }
            })
        }
    }
    
    func requestAccessToken(withCompletion completion:OIDAuthCallback){
        self.authState?.withFreshTokensPerformAction({ (accessToken, idToken, error) in
            completion(token: accessToken,error)
        })
    }
    
}