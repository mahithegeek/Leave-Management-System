//
//  Reporter.swift
//  LexmarkHub
//
//  Created by Kofax on 26/09/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import Foundation

let EMPLOYEE_ID_KEY:String = "emp_id"
let FIRST_NAME_KEY:String = "first_name"
let EMAIL_KEY:String = "email"
let AVAILABLE_KEY:String = "available"

class Reporter: NSObject {
    fileprivate (set)var firstName, email: String
    fileprivate (set)var availableLeaves, empId: NSInteger

    init(withDictionary dict:NSDictionary){
       print(dict)
        self.firstName = dict[FIRST_NAME_KEY] as! String
        self.email = dict[EMAIL_KEY] as! String
        self.availableLeaves = dict[AVAILABLE_KEY] as! NSInteger
        self.empId = dict[EMPLOYEE_ID_KEY] as! NSInteger
        super.init()
    }
}
