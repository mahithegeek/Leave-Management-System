//
//  KMCThreading.swift
//  KMC
//
//  Created by Harendra Singh on 10/12/15.
//  Copyright © 2015 Harendra Singh. All rights reserved.
//

import Foundation

class LMSThreading {
    
    class func dispatchOnMain(withBlock main: @escaping (Void) -> Void) {
        DispatchQueue.main.async(execute: {
            main()
        })
    }
    
    class func disptachOnBackground(withBlock background: @escaping (Void) -> Void) {
        
       DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
        autoreleasepool {
            
            background()
        }
       }
        
    }
    
}
