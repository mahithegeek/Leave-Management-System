//
//  LeaveRequest.swift
//  LeaveManagementSystem
//
//  Created by Durga on 23/08/16.
//  Copyright © 2016 Srilatha. All rights reserved.
//

import Foundation

class LeaveRequest: NSObject {
    var requestId: NSNumber
    var status:String
    var leave: Leave
    init(requestId: NSNumber, status: String, leave: Leave ){
        self.requestId = requestId
        self.status = status
        self.leave = leave
    }
}
