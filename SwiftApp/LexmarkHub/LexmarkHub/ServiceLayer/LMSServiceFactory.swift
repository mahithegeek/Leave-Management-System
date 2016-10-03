//
//  LMSFactory.swift
//  LexmarkHub
//
//  Created by Kofax on 22/09/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import Foundation
import Alamofire

typealias lmsCallback = (NSDictionary?,NSError?) -> Void
typealias reportiesCallback = (NSArray?,NSError?) -> Void
typealias responseCallback = (AnyObject?,NSError?) -> Void

let successCode = 200

class LMSServiceFactory: BaseServiceFactory {
    
    private static let lmsFactorySharedInstance:LMSServiceFactory = LMSServiceFactory()
    private override init(){
        super.init()
    }
    class func sharedInstance()->LMSServiceFactory{
        return lmsFactorySharedInstance
    }
    
    func getAvilableLeaves(withURL url:String, withParams parameters: [String : AnyObject], completion:lmsCallback){
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: self.headers).responseJSON{ response in
           
            if let JSON = response.result.value{
                let responseArray = JSON as? NSArray
                if responseArray != nil {
                    completion(responseArray!.firstObject as? NSDictionary, response.result.error)
                } else {
                    completion(nil, response.result.error)
                }
                
            }else{
                completion(nil,response.result.error)
            }
        }
    }
    
    func getUsers(withURL url:String, withParams parameters: [String : AnyObject], completion:reportiesCallback){
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: self.headers).responseJSON{ response in
            
            if let JSON = response.result.value{
                completion(JSON as? NSArray, response.result.error)
                
            }else{
                completion(nil,response.result.error)
            }
        }
    }
    
    func getLeaveRequests(withURL url:String, withParams parameters: [String : AnyObject], completion:reportiesCallback){
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: self.headers).responseJSON{ response in
            
            if response.response?.statusCode == successCode {
                if let JSON = response.result.value{
                    let leaveRquestsDict = JSON as? NSDictionary
                    completion(leaveRquestsDict!["leaverequests"]
                        as? NSArray, response.result.error)
                    
                }else{
                    completion(nil,response.result.error)
                }

            }
            else {
                if let JSON = response.result.value{
                    let errorDict = JSON as? NSDictionary
                    completion(nil, self.getError(FromDict: errorDict!, errorCode: (response.response?.statusCode)!))
                } else {
                    completion(nil,response.result.error)
                }
                
            }
            
            
        }
    }
    
    func applyLeave(withURL url:String, withParams parameters: [String : AnyObject], completion:lmsCallback){
        
        Alamofire.request(.POST, url, parameters: parameters, encoding: .JSON, headers: self.headers).responseJSON{ response in
            
            if response.response?.statusCode == successCode {
                if let JSON = response.result.value{
                    completion(JSON as? NSDictionary, response.result.error)
                    
                }else{
                    completion(nil,response.result.error)
                }
            }
            else {
                if let JSON = response.result.value{
                    let errorDict = JSON as? NSDictionary
                    completion(nil, self.getError(FromDict: errorDict!, errorCode: (response.response?.statusCode)!))
                } else {
                    completion(nil,response.result.error)
                }

            }
            
        }
    }
    
    //Generating error if user selects invalid dates for applying leave.
    
    func getError(FromDict dict:NSDictionary, errorCode:Int) -> NSError {
        
        let userInfo: [NSObject : AnyObject] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("Unauthorized", value: dict["description"] as! String, comment: ""),
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("Unauthorized", value: dict["description"] as! String, comment: "")
        ]
        let err = NSError(domain: "ShiploopHttpResponseErrorDomain", code: errorCode, userInfo: userInfo)
        
        return err
    }
}