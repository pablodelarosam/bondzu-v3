//
//  SignUpViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado


import UIKit
import Parse
import ParseFacebookUtilsV4

class LoginViewController: LoginGenericViewController , UITextFieldDelegate {

    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var loginFB: UIButton!
    
    @IBOutlet weak var profile: UIImageView!
    
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Log In", comment: "")
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
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

  
    
    @IBAction func registerFacebook(sender: AnyObject) {
        loading = LoadingView(view: self.view)
        let lm = LoginManager()
        lm.loginWithFacebook(self, finishingDelegate: self)
    }
    
    
    @IBAction func login(sender: UIButton){
        
        guard mail.text?.characters.count != 0 else{
            let alert = UIAlertController(title: NSLocalizedString("Empty mail", comment: ""), message: NSLocalizedString("Invalid email, please try again", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {_ in self.mail.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        guard pass.text?.characters.count >= 1 else{
            let alert = UIAlertController(title: NSLocalizedString("Empty password", comment: ""), message: NSLocalizedString("Please introduce your password", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {_ in self.pass.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }

        self.loading = LoadingView(view: self.view)
        let lm = LoginManager()
        lm.login(mail.text!, password: pass.text!, finishingDelegate: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        mail.text = ""
        pass.text = ""
        super.prepareForSegue(segue, sender: sender)
    }
}
