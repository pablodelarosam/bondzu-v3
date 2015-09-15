//
//  LoginViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse
//import ParseFacebookUtilsV4

import MobileCoreServices


class LoginViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var name: UITextField!

    @IBOutlet weak var join: UIButton!
    @IBOutlet weak var joinfb: UIButton!
    
    @IBOutlet weak var profile: UIImageView!
    var hasImage = false
    
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
        profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "changeIcon"))
        profile.userInteractionEnabled = true
        
        profile.layer.cornerRadius = 75/2
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    @IBAction func login(sender: UIButton)
    {
        /*let vc : UITabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("Tabs") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil);*/
        
        if let _ =  PFUser.logInWithUsername("demouser@demo.com", password: "demo_user"){
            self.performSegueWithIdentifier("loginSegue", sender: self)
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

    func changeIcon(){
        let controller = UIAlertController(title: "Attach image", message: "Select an image to attach to your profile", preferredStyle: .ActionSheet)
        
        controller.addAction(UIAlertAction(title: "Take picture", style: .Default, handler: {
            a in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.Camera
                controller.mediaTypes = [kUTTypeImage as String]
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }))
        controller.addAction(UIAlertAction(title: "Select from library", style: .Default, handler: {
            a in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                let controller = UIImagePickerController()
                controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                controller.mediaTypes = [kUTTypeImage as String]
                controller.allowsEditing = true
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }))
        if(hasImage){
            controller.addAction(UIAlertAction(title: "Delete image", style: .Destructive, handler: {
                a in
                self.profile.image = UIImage(named: "profile_pic")
                self.hasImage = false
            }))
        }
        
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            a in
        }))
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        let originalmage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        if let image = editedImage{
            profile.image = image
            hasImage = true
        }
        else if let image = originalmage{
            profile.image = image
            hasImage = true
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func register(){
        guard name.text?.characters.count != 0 else{
            let alert = UIAlertController(title: "Empty name", message: "Your name should not be empty", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {_ in self.name.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        guard mail.text?.characters.count != 0 else{
            let alert = UIAlertController(title: "Empty mail", message: "Your mail should not be empty", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {_ in self.mail.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        guard (mail.text?.isValidEmail() == true) else{
            let alert = UIAlertController(title: "Invalid mail", message: "Please insert a valid mail", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {_ in self.mail.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        guard pass.text?.characters.count >= 5 else{
            let alert = UIAlertController(title: "Empty password", message: "Your password should contain at least 5 characters", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {_ in self.pass.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let query = PFQuery(className: "User")
        query.whereKey("username", equalTo: (self.mail.text?.lowercaseString)!)
        query.countObjectsInBackgroundWithBlock {
            (v, e) -> Void in
            guard e == nil else{
                let a = UIAlertController(title: "Error", message: "Unable to create user. Please try again later", preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                return
            }
            guard v == 0 else{
                let a = UIAlertController(title: "Error", message: "The email is already registered", preferredStyle: .Alert)
                a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                return
            }
        }
        
        
        func registerFinal(){
            let user = PFUser()
            user.username = self.mail.text?.lowercaseString
            user.password = self.pass.text
            user.email = self.mail.text?.lowercaseString
            user["name"] = self.name.text
            
            if hasImage{
                user["photoFile"] = PFFile(data: UIImagePNGRepresentation(profile.image!)!)
            }
            user.signUpInBackgroundWithBlock(){
                (creado, e) -> Void in
                guard e == nil && creado else{
                    let a = UIAlertController(title: "Error", message: "Unable to create user. Please try again later", preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                    return
                }
                
                PFUser.logInWithUsernameInBackground(self.mail
                    .text!, password: self.pass.text!, block:
                    { (user, error) -> Void in
                        guard error == nil else{
                            let a = UIAlertController(title: "Error", message: "Your user was created but we where unable to log in. Please enter your data in \"login here\"", preferredStyle: .Alert)
                            a.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
                            return
                        }
                        
                        self.performSegueWithIdentifier("loginSegue", sender: self);
                    }
                )
            }
           
        }


        
        
        
        if !hasImage{
            let alert = UIAlertController(title: "Empty profile image", message: "You can add a profile picture. Would you like to do it?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Sure!", style: .Default, handler:{
                _ in
                self.changeIcon()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .Default, handler:{
                _ in
                registerFinal()
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        else{
            registerFinal()
        }
        
    }
    
    @IBAction func registerFacebook(sender: AnyObject) {
        /*let fbPermission = ["user_about_me"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(fbPermission) { (user, error) -> Void in
            if user  == nil{
                print("Uh oh. The user cancelled the Facebook login.")
            } else if (user!.isNew) {
                print("User signed up and logged in through Facebook!")
                print(PFUser.currentUser())
            } else {
                print("User logged in through Facebook!")
            }
        }*/
    }
    /*
    //MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
