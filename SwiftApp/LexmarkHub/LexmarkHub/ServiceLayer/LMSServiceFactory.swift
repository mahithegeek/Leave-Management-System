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
    
    fileprivate static let lmsFactorySharedInstance:LMSServiceFactory = LMSServiceFactory()
    fileprivate override init(){
        super.init()
    }
    class func sharedInstance()->LMSServiceFactory{
        return lmsFactorySharedInstance
    }
    
    func getAvilableLeaves(withURL url:String, withParams parameters: [String : AnyObject], completion:@escaping lmsCallback){
        
        Alamofire.request(url, method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{ response in
           
            if let JSON = response.result.value{
                print(response.result.value)
                let responseArray = JSON as? NSArray
                if responseArray != nil {
                    completion(responseArray!.firstObject as? NSDictionary, response.result.error as NSError?)
                } else {
                    completion(nil, response.result.error as NSError?)
                }
                
            }else{
                completion(nil,response.result.error as NSError?)
            }
        }
    }
    
    func getUsers(withURL url:String, withParams parameters: [String : AnyObject], completion:@escaping reportiesCallback){
        
        Alamofire.request(url, method:.post,  parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{ response in
            
            if let JSON = response.result.value{
                completion(JSON as? NSArray, response.result.error as NSError?)
                
            }else{
                completion(nil,response.result.error as NSError?)
            }
        }
    }
    
    func getLeaveRequests(withURL url:String, withParams parameters: [String : AnyObject], completion:@escaping reportiesCallback){
        
        Alamofire.request(url, method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{ response in
            
            if response.response?.statusCode == successCode {
                print(response.result.value)
                if let JSON = response.result.value{
                    let leaveRquestsDict = JSON as? NSDictionary
                    completion(leaveRquestsDict!["leaveRequests"]
                        as? NSArray, response.result.error as NSError?)
                    
                }else{
                    completion(nil,response.result.error as NSError?)
                }

            }
            else {
                if let JSON = response.result.value{
                    let errorDict = JSON as? NSDictionary
                    completion(nil, self.getError(FromDict: errorDict!, errorCode: (response.response?.statusCode)!))
                } else {
                    completion(nil,response.result.error as NSError?)
                }
                
            }
            
            
        }
    }
    
    func getUserLeaveRequests(withURL url:String, withParams parameters: [String : AnyObject], completion:@escaping reportiesCallback){
        
        Alamofire.request(url, method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{ response in
            
            if response.response?.statusCode == successCode {
                print(response.result.value)
                if let JSON = response.result.value{
                    let leaveRquestsArray = JSON as? NSDictionary
                    completion(leaveRquestsArray!["leaveHistory"]
                        as? NSArray, response.result.error as NSError?)
                    
                }else{
                    completion(nil,response.result.error as NSError?)
                }
                
            }
            else {
                if let JSON = response.result.value{
                    let errorDict = JSON as? NSDictionary
                    completion(nil, self.getError(FromDict: errorDict!, errorCode: (response.response?.statusCode)!))
                } else {
                    completion(nil,response.result.error as NSError?)
                }
                
            }
            
            
        }
    }
    func cancelLeave(withURL url:String, withParams parameters: [String : AnyObject], completion:@escaping lmsCallback){
        
        Alamofire.request(url, method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{ response in
            
            if response.response?.statusCode == successCode {
                if let JSON = response.result.value{
                    completion(JSON as? NSDictionary, response.result.error as NSError?)
                    
                }else{
                    completion(nil,response.result.error as NSError?)
                }
            }
            else {
                if let JSON = response.result.value{
                    let errorDict = JSON as? NSDictionary
                    completion(nil, self.getError(FromDict: errorDict!, errorCode: (response.response?.statusCode)!))
                } else {
                    completion(nil,response.result.error as NSError?)
                }
            }
        }
    }
    
    func applyLeave(withURL url:String, withParams parameters: [String : AnyObject], completion:@escaping lmsCallback){
        
        Alamofire.request(url, method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{ response in
            
            if response.response?.statusCode == successCode {
                if let JSON = response.result.value{
                    completion(JSON as? NSDictionary, response.result.error as NSError?)
                    
                }else{
                    completion(nil,response.result.error as NSError?)
                }
            }
            else {
                if let JSON = response.result.value{
                    let errorDict = JSON as? NSDictionary
                    completion(nil, self.getError(FromDict: errorDict!, errorCode: (response.response?.statusCode)!))
                } else {
                    completion(nil,response.result.error as NSError?)
                }

            }
            
        }
    }
    
    func approveLeave(withURL url:String, withParams parameters: [String : AnyObject], completion:@escaping lmsCallback){
        
        Alamofire.request(url, method:.post, parameters: parameters, encoding: JSONEncoding.default, headers: self.headers).responseJSON{ response in
            
            if response.response?.statusCode == successCode {
                if let JSON = response.result.value{
                    completion(JSON as? NSDictionary, response.result.error as NSError?)
                    
                }else{
                    completion(nil,response.result.error as NSError?)
                }
            }
            else {
                if let JSON = response.result.value{
                    let errorDict = JSON as? NSDictionary
                    completion(nil, self.getError(FromDict: errorDict!, errorCode: (response.response?.statusCode)!))
                } else {
                    completion(nil,response.result.error as NSError?)
                }
                
            }
            
        }
    }
    
    //Generating error if user selects invalid dates for applying leave.
    
    func getError(FromDict dict:NSDictionary, errorCode:Int) -> NSError {
        
        let userInfo: [AnyHashable: Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("Unauthorized", value: dict["description"] as! String, comment: ""),
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("Unauthorized", value: dict["description"] as! String, comment: "")
        ]
        let err = NSError(domain: "ShiploopHttpResponseErrorDomain", code: errorCode, userInfo: userInfo)
        
        return err
    }
}
