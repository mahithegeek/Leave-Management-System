//
//  Employee.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import Foundation

// JSON Keys for Response

let kEmployeeID:String = "empID"
let kFirstName:String = "firstName"
let kLastName:String = "lastName"
let kRole:String = "role"
let kEmail:String = "email"

class Employee: NSObject {
    private (set)var id, role: NSNumber
    private (set)var name,  email: String
    
    init(withDictionary dict:NSDictionary){
        self.id = NSNumber.init(integer: (dict.objectForKey(kEmployeeID)?.integerValue)!)
        
        let firstName:String = dict.objectForKey(kFirstName) as! String
        let lastName:String = dict.objectForKey(kLastName) as! String
        self.name = firstName.stringByAppendingString(lastName)
        
        self.role = NSNumber.init(integer: (dict.objectForKey(kRole)?.integerValue)!)
        self.email = dict.objectForKey(kEmail) as! String
        
        super.init()
    }
}
