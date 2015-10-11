//
//  ForgotPasswordViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/28/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit
import Parse

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var forgot: UIButton!
    @IBOutlet weak var profile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        forgot.layer.borderWidth = 2
        forgot.layer.cornerRadius = 10
        self.forgotPassword.enabled = false;
        forgot.layer.borderColor = forgot.titleLabel!.textColor.CGColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dissmissKeyboards"))
        
        profile.layer.cornerRadius = 75/2
    }

    func dissmissKeyboards(){
        mail.resignFirstResponder()
    }
    
    @IBOutlet weak var forgotPassword: UIButton!
    
    @IBAction func emailChanged(sender: UITextField) {
        if(sender.text!.isValidEmail())
        {
            self.forgotPassword.enabled = true
            forgot.layer.borderColor = forgot.titleLabel!.textColor.CGColor
        }else{
            self.forgotPassword.enabled = false
            forgot.layer.borderColor = forgot.titleLabel!.textColor.CGColor
        }
    }
    
    @IBAction func forgotPassword(sender: UIButton) {
        checkIfNotFacebookUser(self.mail.text!)
    }
    
    
    
    func checkIfNotFacebookUser(email: String)
    {
        
        if let email = self.mail.text as String!{
            if(email.isValidEmail())
            {
                let query = PFUser.query()
                query?.whereKey(TableUserColumnNames.UserName.rawValue, equalTo: email)
                query?.findObjectsInBackgroundWithBlock{
                    (objects: [AnyObject]?, error: NSError?) -> Void in
                    if error == nil
                    {
                        if(objects?.count >= 1)
                        {
                            print(objects)
                            PFUser.requestPasswordResetForEmailInBackground(email);
                            
                            let a = UIAlertController(title: NSLocalizedString("Done", comment: ""), message: NSLocalizedString("Check your email to reset your password", comment: ""), preferredStyle: .Alert)
                            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                style: UIAlertActionStyle.Default,
                                handler: { (alert: UIAlertAction) -> Void in
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                            }))
                            
                            self.presentViewController(a, animated: true, completion: nil)
                        }
                        else
                        {
                            let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Try to log in using Facebook" , comment: ""), preferredStyle: .Alert)
                            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                style: UIAlertActionStyle.Default,
                                handler: { (alert: UIAlertAction) -> Void in
                                    self.navigationController?.popToRootViewControllerAnimated(true)
                            }))
                            
                            self.presentViewController(a, animated: true, completion: nil)
                        }
                    }
                }
                
            }else{
                let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Invalid email, please try again", comment: ""), preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                
                self.presentViewController(a, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
