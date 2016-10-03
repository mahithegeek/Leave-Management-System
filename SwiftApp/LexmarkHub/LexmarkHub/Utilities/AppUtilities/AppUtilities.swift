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
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch ReachabilityError.FailedToCreateWithAddress( _) {
            Log("Unable to setup rechability")
            return
        } catch {}
    }

    func isReachable() -> Bool {
        setupReachability()
        return (self.reachability?.isReachable())!
    }

    func Log(message:String, function:String = #function) {
        if showLogs == true {
            print("\(function): \(message)")
        }
    }
    func dateStringFromDate(date:NSDate) -> String {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //format style. you can change according to yours
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    func dateFromString(dateString:String) -> NSDate {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" //format style. you can change according to yours
        let date = dateFormatter.dateFromString(dateString)
        return date!
    }
}
