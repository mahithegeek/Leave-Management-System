//
//  LoginService.swift
//  LexmarkHub
//
//  Created by Ravi on 9/1/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import Foundation

import Alamofire

typealias LoginCallback = (NSDictionary?,NSError?) -> Void

class LoginService: AnyObject {
    
    fileprivate var urlString:String
    fileprivate let headers = [
        "Accept": "application/json"
    ]
    required init(withURLString url:String){
        self.urlString = url
    }
    
    
    func fireService(withParams params:[String: String], completion:@escaping LoginCallback){
        print(self.urlString)
        

        Alamofire.request(self.urlString, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.headers).responseJSON {response in
            if let JSON = response.result.value{
                completion(JSON as? NSDictionary,nil)
            }else{
                completion(nil,response.result.error as NSError?)
            }
        }
        
    }
}

