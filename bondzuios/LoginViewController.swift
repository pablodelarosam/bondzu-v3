//
//  SignUpViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var loginFB: UIButton!
    
    @IBOutlet weak var profile: UIImageView!
    
    var loading : LoadingView?
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = "Log In"
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        pass.secureTextEntry = true
        login.layer.borderWidth = 2
        login.layer.borderColor = UIColor.whiteColor().CGColor
        
        login.layer.cornerRadius = 10
        loginFB.layer.cornerRadius = 10
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dissmissKeyboards"))
        
        profile.layer.cornerRadius = 75/2
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dissmissKeyboards(){
        pass.resignFirstResponder()
        mail.resignFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == pass{
            login(login)
        }
        return true
    }

    
    @IBAction func registerFacebook(sender: AnyObject) {
        
        
        func process(user : PFUser?, error : NSError?){
            if error != nil{
                print(error)
                
                dispatch_async(dispatch_get_main_queue()){
                    self.loading?.finish()
                    self.loading = nil
                    let a  = UIAlertController(title: "Error", message: "Unable to sign up", preferredStyle: UIAlertControllerStyle.Alert)
                    a.addAction(UIAlertAction(title: "ok", style: .Default, handler: nil))
                    self.presentViewController(a, animated: true, completion: nil)
                }
            }
            else if user!.isNew{
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email,picture.width(100).height(100)"]).startWithCompletionHandler({
                    (connection, dic, error) -> Void in
                    if let dictionary = dic as? Dictionary<String, AnyObject>{
                        let user = PFUser.currentUser()!
                        user["name"] = dictionary["name"] as! String
                        user.password = "\(random())"
                        user["email"] = dictionary["email"] as! String
                        user["photo"] = ((dictionary["picture"] as! Dictionary<String,AnyObject>)["data"]  as! Dictionary<String,AnyObject>)["url"] as! String
                        user.saveInBackgroundWithBlock({
                            (saved, error) -> Void in
                            if error != nil{
                                dispatch_async(dispatch_get_main_queue()){
                                    self.loading?.finish()
                                    self.loading = nil
                                    let a  = UIAlertController(title: "Error", message: "Unable to sign up", preferredStyle: UIAlertControllerStyle.Alert)
                                    a.addAction(UIAlertAction(title: "ok", style: .Default, handler: nil))
                                    self.presentViewController(a, animated: true, completion: nil)
                                }
                                print(error)
                                user.deleteInBackgroundWithBlock({ (del, error) -> Void in
                                    print("Usuario eliminado")
                                })
                            }
                            else{
                                dispatch_async(dispatch_get_main_queue()){
                                    self.loading?.finish()
                                    self.loading = nil
                                    self.performSegueWithIdentifier("catalog", sender: PFUser.currentUser()!)
                                }
                            }
                            
                        })
                    }
                })
            }
            else{
                dispatch_async(dispatch_get_main_queue()){
                    self.loading?.finish()
                    self.loading = nil
                    self.performSegueWithIdentifier("catalog", sender: PFUser.currentUser()!)
                }
            }
        }
        
        
        loading = LoadingView(view: self.view)
        
        let fbPermission = ["user_about_me","email"]
        let login = FBSDKLoginManager()
        login.loginBehavior = .Native
        
        
        if let at = FBSDKAccessToken.currentAccessToken(){
            PFFacebookUtils.logInInBackgroundWithAccessToken(at, block: process)
            return
        }
        
        login.logInWithReadPermissions(fbPermission, fromViewController: self){
            (result, error) -> Void in
            if error != nil{
                dispatch_async(dispatch_get_main_queue()){
                    print(error)
                    self.loading?.finish()
                    self.loading = nil
                }
            }
            else if result.isCancelled{
                dispatch_async(dispatch_get_main_queue()){
                    self.loading?.finish()
                    self.loading = nil
                }
                print("Cancelado")
            }
            else{
                PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: process)
            }
        }
        
        
    }

    
    @IBAction func login(sender: UIButton)
    {
        
        guard mail.text?.characters.count != 0 else{
            let alert = UIAlertController(title: "Empty mail", message: "Please introduce your mail", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {_ in self.mail.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        guard pass.text?.characters.count >= 1 else{
            let alert = UIAlertController(title: "Empty password", message: "Please introduce your password", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {_ in self.pass.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }

        self.loading = LoadingView(view: self.view)
        
        PFUser.logInWithUsernameInBackground(mail.text!, password: pass.text!) {
            (user, error) -> Void in
            guard error == nil else{
                dispatch_async(dispatch_get_main_queue()){
                    self.loading?.finish()
                    self.loading = nil
                    let ac = UIAlertController(title: "Error", message: "Unable to login.\nPlease check your login data and your Internet connection", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }

                return
            }
            if let logedUser = user{
                dispatch_async(dispatch_get_main_queue()){
                    self.loading?.finish()
                    self.loading = nil
                    self.performSegueWithIdentifier("catalog", sender: logedUser)
                }
            }
            else{
                dispatch_async(dispatch_get_main_queue()){
                    self.loading?.finish()
                    self.loading = nil
                    let ac = UIAlertController(title: "Error", message: "Unable to login.\nPlease check your login data", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        mail.text = ""
        pass.text = ""
    }
}
