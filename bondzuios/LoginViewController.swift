//
//  LoginViewController.swift
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
    @IBOutlet weak var name: UITextField!

    @IBOutlet weak var join: UIButton!
    @IBOutlet weak var joinfb: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.barStyle = .Black
        self.navigationController?.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        pass.secureTextEntry = true
        join.layer.borderWidth = 2
        join.layer.borderColor = UIColor.whiteColor().CGColor
        
        join.layer.cornerRadius = 10
        joinfb.layer.cornerRadius = 10
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dissmissKeyboards"))
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    @IBAction func login(sender: UIButton)
    {
        /*let vc : UITabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("Tabs") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil);*/
        let usuario = PFUser.logInWithUsername("demouser@demo.com", password: "demo_user")
        if usuario != nil{
            self.performSegueWithIdentifier("loginSegue", sender: self);
        }
        else{
            print("ÑO");
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dissmissKeyboards(){
        name.resignFirstResponder()
        pass.resignFirstResponder()
        mail.resignFirstResponder()
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
