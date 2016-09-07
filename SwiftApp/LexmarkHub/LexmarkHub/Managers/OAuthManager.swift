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
        let authState:OIDAuthState? = NSKeyedUnarchiver .unarchiveObjectWithData(archivedAuthState! as! NSData) as? OIDAuthState
        if authState != nil{
            self.setAuthorizationState(withState: authState)
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
            self.idToken = idToken
        })
    }
    
}