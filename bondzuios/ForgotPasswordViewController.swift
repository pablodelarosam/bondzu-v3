//
//  ForgotPasswordViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/28/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit
import Parse
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var forgot: UIButton!
    @IBOutlet weak var profile: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        forgot.layer.borderWidth = 2
        forgot.layer.cornerRadius = 10
        self.forgotPassword.isEnabled = false;
        forgot.layer.borderColor = forgot.titleLabel!.textColor.cgColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordViewController.dissmissKeyboards)))
        
        profile.layer.cornerRadius = 75/2
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func dissmissKeyboards(){
        mail.resignFirstResponder()
    }
    
    @IBOutlet weak var forgotPassword: UIButton!
    
    @IBAction func emailChanged(_ sender: UITextField) {
        if(sender.text!.isValidEmail())
        {
            self.forgotPassword.isEnabled = true
            forgot.layer.borderColor = forgot.titleLabel!.textColor.cgColor
        }else{
            self.forgotPassword.isEnabled = false
            forgot.layer.borderColor = forgot.titleLabel!.textColor.cgColor
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        checkIfNotFacebookUser(self.mail.text!)
    }
    
    
    
    func checkIfNotFacebookUser(_ email: String)
    {
        
        if let email = self.mail.text as String!{
            if(email.isValidEmail())
            {
                let query = PFUser.query()
                query?.whereKey(TableUserColumnNames.UserName.rawValue, equalTo: email)
                query?.findObjectsInBackground{
                    (objects: [PFObject]?, error: Error?) -> Void in
                    if error == nil
                    {
                        if(objects?.count >= 1)
                        {
                            print(objects!)
                            PFUser.requestPasswordResetForEmail(inBackground: email);
                            
                            let a = UIAlertController(title: NSLocalizedString("Done", comment: ""), message: NSLocalizedString("Check your email to reset your password", comment: ""), preferredStyle: .alert)
                            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                style: UIAlertActionStyle.default,
                                handler: { (alert: UIAlertAction) -> Void in
                                    self.navigationController?.popToRootViewController(animated: true)
                            }))
                            
                            self.present(a, animated: true, completion: nil)
                        }
                        else
                        {
                            let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Try to log in using Facebook" , comment: ""), preferredStyle: .alert)
                            a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""),
                                style: UIAlertActionStyle.default,
                                handler: { (alert: UIAlertAction) -> Void in
                                    self.navigationController?.popToRootViewController(animated: true)
                            }))
                            
                            self.present(a, animated: true, completion: nil)
                        }
                    }
                }
                
            }else{
                let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Invalid email, please try again", comment: ""), preferredStyle: .alert)
                a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                
                self.present(a, animated: true, completion: nil)
            }
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
