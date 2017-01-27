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
    
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait

    }
    
    
    open override var shouldAutorotate : Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate
        }
        return super.shouldAutorotate
    }
    
    open override var prefersStatusBarHidden : Bool {
        if let vc = selectedViewController{
            return vc.prefersStatusBarHidden
        }
        
        return false
    }
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return self.selectedViewController
    }
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return self.selectedViewController
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

extension UIAlertController {
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    open override var shouldAutorotate : Bool {
        return false
    }
}

extension UINavigationController{
   
    func logoutUser(){
        (UIApplication.shared.delegate as! AppDelegate).user = nil
        FBSDKLoginManager().logOut()
        PFUser.logOutInBackground { (error) -> Void in
            if error == nil{
                DispatchQueue.main.async{
                    self.popToRootViewController(animated: true)
                }
            }
        }
    }
    
}

extension String {

    func isValidEmail() -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluate(with: self)

        return result
        
    }
}

extension CGPoint{

    static func originForCenteringView(_ view : UIView, inView : UIView) -> CGPoint{
        return CGPoint(x: inView.frame.size.width / 2 - view.frame.size.width / 2, y: inView.frame.size.height / 2 - view.frame.size.height / 2)
    }
    
}
