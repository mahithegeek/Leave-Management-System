//
//  Popups.swift
//
//  Created by Tom Swindell on 25/05/2015.
//  Copyright (c) 2015 Tom Swindell. All rights reserved.
//

import Foundation
import UIKit
class Popups {
//    private static var __once: () = {
//            _ = Popups.__once
//        }()
//    class var SharedInstance: Popups {
//        struct Static {
//            static var onceToken: Int = 0
//            static var instance: Popups? = nil
//        }
//        _ = Popups.__once
//        return Static.instance!
//    }
    
    static let sharedInstance : Popups = {
        let instance = Popups()
        return instance
    }()
    
    var alertComletion : ((String) -> Void)!
    var alertButtons : [String]!
    
    func ShowAlert(_ sender: UIViewController, title: String, message: String, buttons : [String], completion: ((_ buttonPressed: String) -> Void)?) {
        
        let aboveIOS7 = floor(NSFoundationVersionNumber) > floor(NSFoundationVersionNumber_iOS_7_1)
        if(aboveIOS7) {
            
            let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for b in buttons {
                
                alertView.addAction(UIAlertAction(title: b, style: UIAlertActionStyle.default, handler: {
                    (action : UIAlertAction) -> Void in
                    completion!(action.title!)
                }))
            }
            sender.present(alertView, animated: true, completion: nil)
            
        } else {
            
            self.alertComletion = completion
            self.alertButtons = buttons
            let alertView  = UIAlertView()
            alertView.delegate = self
            alertView.title = title
            alertView.message = message
            for b in buttons {
                
                alertView.addButton(withTitle: b)
                
            }
            alertView.show()
        }
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(self.alertComletion != nil) {
            self.alertComletion!(self.alertButtons[buttonIndex])
        }
    }
    
    
    
    func ShowPopup(_ title : String, message : String) {
        let alert: UIAlertView = UIAlertView()
        alert.title = title
        alert.message = message
        alert.addButton(withTitle: "Ok")
        alert.show()
    }
}
