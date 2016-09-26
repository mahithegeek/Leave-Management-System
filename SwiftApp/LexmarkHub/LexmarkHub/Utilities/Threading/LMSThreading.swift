//
//  KMCThreading.swift
//  KMC
//
//  Created by Harendra Singh on 10/12/15.
//  Copyright © 2015 Harendra Singh. All rights reserved.
//

import Foundation

class LMSThreading {
    
    class func dispatchOnMain(withBlock main: (Void) -> Void) {
        dispatch_async(dispatch_get_main_queue(), {
            main()
        })
    }
    
    class func disptachOnBackground(withBlock background: (Void) -> Void) {
        
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
        autoreleasepool {
            
            background()
        }
       }
        
    }
    
}
