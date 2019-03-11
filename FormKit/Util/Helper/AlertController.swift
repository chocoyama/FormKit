//
//  AlertControllerHelper.swift
//  FormKit
//
//  Created by Takuya Yokoyama on 2019/03/05.
//  Copyright © 2019 chocoyama. All rights reserved.
//

import Foundation
import UIKit

class AlertController {
    private static var rootWindow: UIWindow?
    private static var alertWindow: UIWindow?
    
    
    static func show(_ alertController: UIAlertController) {
        escapeKeyWindow()
        
        alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow?.backgroundColor = .clear
        alertWindow?.rootViewController = UIViewController()
        alertWindow?.windowLevel = .alert
        alertWindow?.makeKeyAndVisible()
        alertWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    static func done() {
        restoreKeyWindow()
    }
    
    private static func escapeKeyWindow() {
        rootWindow = UIApplication.shared.keyWindow
    }
    
    private static func restoreKeyWindow() {
        alertWindow?.isHidden = true
        alertWindow?.removeFromSuperview()
        rootWindow?.makeKeyAndVisible()
        
        rootWindow = nil
        alertWindow = nil
    }
}

