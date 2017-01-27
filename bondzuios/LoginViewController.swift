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


class LoginViewController: LoginGenericViewController , UITextFieldDelegate {

    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pass: UITextField!
    
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var loginFB: UIButton!
    
    @IBOutlet weak var profile: UIImageView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Log In", comment: "")
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        pass.isSecureTextEntry = true
        login.layer.borderWidth = 2
        login.layer.borderColor = UIColor.white.cgColor
        
        login.layer.cornerRadius = 10
        loginFB.layer.cornerRadius = 10
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dissmissKeyboards)))
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == pass{
            login(login)
        }
        return true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

  
    
    @IBAction func registerFacebook(_ sender: AnyObject) {
        loading = LoadingView(view: self.view)
        let lm = LoginManager()
        lm.loginWithFacebook(self, finishingDelegate: self)
    }
    
    
    @IBAction func login(_ sender: UIButton){
        
        guard mail.text?.characters.count != 0 else{
            let alert = UIAlertController(title: NSLocalizedString("Empty mail", comment: ""), message: NSLocalizedString("Invalid email, please try again", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {_ in self.mail.becomeFirstResponder()}))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard pass.text?.characters.count >= 1 else{
            let alert = UIAlertController(title: NSLocalizedString("Empty password", comment: ""), message: NSLocalizedString("Please introduce your password", comment: ""), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {_ in self.pass.becomeFirstResponder()}))
            self.present(alert, animated: true, completion: nil)
            return
        }

        self.loading = LoadingView(view: self.view)
        let lm = LoginManager()
        lm.login(mail.text!, password: pass.text!, finishingDelegate: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        mail.text = ""
        pass.text = ""
        super.prepare(for: segue, sender: sender)
    }
}
