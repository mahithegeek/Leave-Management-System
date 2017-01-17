//
//  AppUtilities.swift
//  LexmarkHub
//
//  Created by Rambabu N on 8/30/16.
//  Copyright © 2016 kofax. All rights reserved.
//

import UIKit

class AppUtilities: NSObject {
    var reachability: Reachability?
    let showLogs:Bool = true

    func setupReachability() {
        let reachability = Reachability.init()
        self.reachability = reachability
    }

    func isReachable() -> Bool {
        setupReachability()
        return (self.reachability?.isReachable)!
    }

    func Log(_ message:String, function:String = #function) {
        if showLogs == true {
            print("\(function): \(message)")
        }
    }
    func dateStringFromDate(_ date:Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //format style. you can change according to yours
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    func dateFromString(_ dateString:String) -> Date {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //format style. you can change according to yours
        let date = dateFormatter.date(from: dateString)
        return date!
    }
}
