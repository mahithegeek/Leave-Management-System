//
//  Leave.swift
//  LeaveManagementSystem
//
//  Created by Durga on 23/08/16.
//  Copyright © 2016 Srilatha. All rights reserved.
//

import Foundation

class Leave: NSObject {
    var reason:String?
    var employee: Employee?
    var startDate, endDate:Date?
    var leaveType:String?
    var isHalfDay:Bool?
    init(reason:String, employee: Employee?, startDate: Date?, endDate: Date?,isHalfDay: Bool,leaveType:String){
        self.reason = reason
        self.employee = employee
        self.startDate = startDate
        self.endDate = endDate
        self.leaveType = leaveType
        self.isHalfDay = isHalfDay
    }
}
