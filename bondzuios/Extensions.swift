//
//  NavControllerExtension.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 18/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import Foundation
import UIKit
import Parse

extension UITabBarController {
    
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    public override func shouldAutorotate() -> Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate()
        }
        return super.shouldAutorotate()
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        if let vc = selectedViewController{
            return vc.prefersStatusBarHidden()
        }
        
        return false
    }
    
    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return self.selectedViewController
    }
    
    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.selectedViewController
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

extension UIAlertController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    public override func shouldAutorotate() -> Bool {
        return false
    }
}

extension UINavigationController{
   
    func logoutUser(){
        FBSDKLoginManager().logOut()
        PFUser.logOutInBackgroundWithBlock { (error) -> Void in
            if error == nil{
                dispatch_async(dispatch_get_main_queue()){
                    self.popToRootViewControllerAnimated(true)
                }
            }
        }
    }
    
}

extension String {

    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluateWithObject(self)

        return result
        
    }
}