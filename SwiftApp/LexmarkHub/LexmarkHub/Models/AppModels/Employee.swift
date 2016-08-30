//
//  Employee.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import Foundation

class Employee: NSObject {
    var id, totalLeaves, availableLeaves: NSNumber
    var name, role, email: String
    init(id: NSNumber, name: String, role: String, email: String, totalLeaves: NSNumber, availableLeaves: NSNumber){
        self.id = id
        self.name = name
        self.role = role
        self.email = email
        self.totalLeaves = totalLeaves
        self.availableLeaves = availableLeaves
    }
}
