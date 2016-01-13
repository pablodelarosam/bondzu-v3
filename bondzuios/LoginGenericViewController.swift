//
//  LoginGenericViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/11/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

/**
 This class provides the starting point for Login and sign up controller.

 It contains several methods, including the implementation of the login manager result protocol.
 */
class LoginGenericViewController: UIViewController, LoginManagerResultDelegate {

    var loading : LoadingView?

    //MARK: Login Manager Result Delegate implementation
    
    /**
    In this implementantion. On failing this mathod is responsable of the following:
    
    * Dismiss the loading view
    * Move the user to the catalog
    
    */
    func loginManagerDidLogin(user : PFUser){
        self.loading?.finish()
        self.loading = nil
        self.performSegueWithIdentifier("loginSegue", sender: PFUser.currentUser()!)
    }
    
    /**
     In this implementantion. On failing this mathod is responsable of the following:
     
     * Dismiss the loading view
     * Move the user to the catalog
     
     */
    func loginManagerDidRegister(user : PFUser){
        self.loading?.finish()
        self.loading = nil
        self.performSegueWithIdentifier("loginSegue", sender: PFUser.currentUser()!)
    }
    
    /**
     In this implementantion. On failing this mathod is responsable of the following:
     
     * Dismiss the loading view
     * Tell the user something went wrong
     */
    func loginManagerDidFailed(){
        self.loading?.finish()
        self.loading = nil
        let a  = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
        a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
        self.presentViewController(a, animated: true, completion: nil)
        
        
        //NSLocalizedString("The email is already registered", comment: "")
    }
    
    /**
     In this implementantion. On Cancel this mathod is responsable of the following:
     
     * Dismiss the loading view
     */
    func loginManagerDidCanceled(){
        self.loading?.finish()
        self.loading = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "loginSegue"{
            let destVC = segue.destinationViewController as! CatalogViewController
            destVC.user = Usuario(object: sender as! PFObject, loadImage: true, imageLoaderObserver: nil, userTypeObserver: nil)
            (self.navigationController as! BondzuNavigationController).user = destVC.user
        }
    }

}
