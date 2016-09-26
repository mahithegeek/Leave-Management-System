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
}