//
//  LoginViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

/*
    Affected #25
    registerFinal
    registerFacebook
*/

import UIKit
import Parse
import FBSDKCoreKit
import WebKit
import ParseFacebookUtilsV4

import MobileCoreServices


class SignUpViewController : UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var mail: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var name: UITextField!

    @IBOutlet weak var join: UIButton!
    @IBOutlet weak var joinfb: UIButton!
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var termsButton: UIButton!

   var done: UIBarButtonItem!
    
    weak var webView : WKWebView?
    
    var hasImage = false
    
    var loading : LoadingView?
    var activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    
    @IBAction func showTerms(sender: AnyObject) {
        let w = WKWebView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height), configuration: WKWebViewConfiguration())
        w.scrollView.contentInset = UIEdgeInsets(top: navigationController!.navigationBar.frame.size.height, left: 10, bottom: 10, right: 10)
        let request = NSURLRequest(URL: privacyURL!)
        w.loadRequest(request)
        view.addSubview(w)
        webView = w
        webView?.navigationDelegate = self
        UIView.animateWithDuration(0.7, animations: {
            self.webView!.frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.webView!.frame.width, height: self.webView!.frame.height)
            })
        
        navigationItem.leftBarButtonItem = done
        w.addSubview(activityView)
        activityView.center = w.center
        activityView.startAnimating()
    }
    
    @IBAction func clickedDone(sender: AnyObject) {
        webView?.navigationDelegate = nil
        navigationItem.leftBarButtonItem = nil
        webView?.stopLoading()
        UIView.animateWithDuration(0.7, animations: {
            self.webView!.frame = CGRect(x: 0, y: self.view.frame.height, width: self.webView!.frame.width, height: self.webView!.frame.height)
            }, completion: { _ in
                self.webView?.removeFromSuperview()
        })
        
        if activityView.isAnimating(){
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Sign Up", comment: "")
        super.viewDidAppear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
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
        
        if let user = PFUser.currentUser(){
            performSegueWithIdentifier("loginSegue", sender: user)
        }
        
        termsButton.titleLabel!.adjustsFontSizeToFitWidth = true
        done = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style: .Done, target: self, action: "clickedDone:")
        
        activityView.color = UIColor.orangeColor()
    }
    
    /*
    @IBAction func login(sender: UIButton)
    {
        /*let vc : UITabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("Tabs") as! UITabBarController
        self.presentViewController(vc, animated: true, completion: nil);*/
        
        if let _ =  PFUser.logInWithUsername("demouser@demo.com", password: "demo_user"){
            self.performSegueWithIdentifier("loginSegue", sender: self)
        }
        
    }
    */
    
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
        let controller = UIAlertController(title: NSLocalizedString("Attach image", comment: ""), message: NSLocalizedString("Select an image to set as profile picture", comment: ""), preferredStyle: .ActionSheet)
        
        controller.addAction(UIAlertAction(title: NSLocalizedString("Take picture", comment: ""), style: .Default, handler: {
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
        controller.addAction(UIAlertAction(title: NSLocalizedString("Select from library", comment: ""), style: .Default, handler: {
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
            controller.addAction(UIAlertAction(title: NSLocalizedString("Delete image", comment: ""), style: .Destructive, handler: {
                a in
                self.profile.image = UIImage(named: "profile_pic")
                self.hasImage = false
            }))
        }
        
        controller.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: {
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
            let alert = UIAlertController(title: NSLocalizedString("Empty name", comment: ""), message: NSLocalizedString("Your name should not be empty", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {_ in self.name.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        guard mail.text?.characters.count != 0 else{
            let alert = UIAlertController(title: NSLocalizedString("Empty mail", comment: ""), message: NSLocalizedString("Your mail should not be empty", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {_ in self.mail.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        guard (mail.text?.isValidEmail() == true) else{
            let alert = UIAlertController(title: NSLocalizedString("Invalid mail", comment: ""), message: NSLocalizedString("Please insert a valid email address", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {_ in self.mail.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        guard pass.text?.characters.count >= 5 else{
            let alert = UIAlertController(title: NSLocalizedString("Invalid password", comment: ""), message: NSLocalizedString("Your password should contain at least 5 characters", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {_ in self.pass.becomeFirstResponder()}))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        self.loading = LoadingView(view: self.view)
        
        let query = PFQuery(className: TableNames.User.rawValue)
        query.whereKey(TableUserColumnNames.UserName.rawValue, equalTo: (self.mail.text?.lowercaseString)!)
        query.countObjectsInBackgroundWithBlock {
            (v, e) -> Void in
            guard e == nil else{
                
                dispatch_async(dispatch_get_main_queue()){

                    self.loading?.finish()
                    self.loading = nil
                    
                    let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                    self.presentViewController(a, animated: true, completion: nil)
                }
                
                return
            }
            guard v == 0 else{
                
                
                dispatch_async(dispatch_get_main_queue()){
                    self.loading?.finish()
                    self.loading = nil
                    let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("The email is already registered", comment: ""), preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                    
                    self.presentViewController(a, animated: true, completion: nil)

                }
                return
            }
        }
        
        
        func registerFinal(){
            let user = PFUser()
            user.username = self.mail.text?.lowercaseString
            user.password = self.pass.text
            user.email = self.mail.text?.lowercaseString
            user[TableUserColumnNames.Name.rawValue] = self.name.text
            
            if hasImage{
                user[TableUserColumnNames.PhotoFile.rawValue] = PFFile(data: UIImagePNGRepresentation(profile.image!)!)
            }
            
                
            let dic : [String: String] =
            [
                "email" : self.mail.text!,
                "description" : "Cuenta creada para \(self.mail.text!)"
            ]
                
            PFCloud.callFunctionInBackground(PFCloudFunctionNames.CreateCustomer.rawValue, withParameters: dic) { (result: AnyObject?, error: NSError?) in
                print("create Customer result = \(result)")
                
                if(error == nil)
                {
                    do {
                        if let data = result?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                            
                            let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
                            if let jsonDict = jsonDict {
                                // work with dictionary here
                                let key = "id";
                                print("customer_id: \(jsonDict[key])")
                                if let id = jsonDict[key] as? String{
                                    user[TableUserColumnNames.StripeID.rawValue] = id
                                    
                                    user.signUpInBackgroundWithBlock(){
                                        (creado, e) -> Void in
                                        guard e == nil && creado else{
                                            
                                            dispatch_async(dispatch_get_main_queue()){
                                                self.loading?.finish()
                                                self.loading = nil
                                                let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .Alert)
                                                a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                                                
                                                self.presentViewController(a, animated: true, completion: nil)
                                            }
                                            
                                            
                                            return
                                        }
                                    }
                                    print(PFUser.currentUser())
                                    self.loading?.finish()
                                    self.loading = nil
                                    self.performSegueWithIdentifier("loginSegue", sender: self);
                                }
                            }
                            
                        }
                    } catch let error as NSError {
                        // error handling
                        print("error : \(error)")
                        self.loading?.finish()
                        self.loading = nil
                        let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .Alert)
                        a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                        
                        self.presentViewController(a, animated: true, completion: nil)
                    }
                }
                else
                {
                    self.loading?.finish()
                    self.loading = nil
                    let a = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .Alert)
                    a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                    
                    self.presentViewController(a, animated: true, completion: nil)
                }
            }
        }


        
        
        
        if !hasImage{
            self.loading?.finish()
            self.loading = nil
            let alert = UIAlertController(title: NSLocalizedString("Empty profile image", comment: ""), message: NSLocalizedString("You can add a profile picture. Would you like to do it?", comment: ""), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Sure!", comment: ""), style: .Default, handler:{
                _ in
                self.changeIcon()
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .Default, handler:{
                _ in
                self.loading = LoadingView(view: self.view)
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
        
        
        func process(user : PFUser?, error : NSError?){
            if error != nil{
                print(error)
                
                dispatch_async(dispatch_get_main_queue()){
                    self.loading?.finish()
                    self.loading = nil
                    let a  = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                    self.presentViewController(a, animated: true, completion: nil)
                }
            }
            else if user!.isNew{
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email,picture.width(100).height(100)"]).startWithCompletionHandler({
                    (connection, dic, error) -> Void in
                    if let dictionary = dic as? Dictionary<String, AnyObject>{
                        let user = PFUser.currentUser()!
                        user[TableUserColumnNames.Name.rawValue] = dictionary["name"] as! String
                        user.password = "\(random())"
                        user[TableUserColumnNames.Mail.rawValue] = dictionary["email"] as! String
                        user[TableUserColumnNames.PhotoURL.rawValue] = ((dictionary["picture"] as! Dictionary<String,AnyObject>)["data"]  as! Dictionary<String,AnyObject>)["url"] as! String
                        user.saveInBackgroundWithBlock({
                            (saved, error) -> Void in
                            if error != nil{
                                dispatch_async(dispatch_get_main_queue()){
                                    self.loading?.finish()
                                    self.loading = nil
                                    let a  = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                                    a.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                                    self.presentViewController(a, animated: true, completion: nil)
                                }
                                print(error)
                                user.deleteInBackgroundWithBlock({ (del, error) -> Void in
                                })
                            }
                            else{
                                dispatch_async(dispatch_get_main_queue()){
                                    self.loading?.finish()
                                    self.loading = nil
                                    self.performSegueWithIdentifier("loginSegue", sender: PFUser.currentUser()!)
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
                    self.performSegueWithIdentifier("loginSegue", sender: PFUser.currentUser()!)
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
            }
            else{
                PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: process)
            }
        }
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        mail.text = ""
        pass.text = ""
        name.text = ""
        hasImage = false
        profile.image = UIImage(named: "profile_pic")
    }
        
    //TODO ver porque en community no jala el indicator

    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        if let w = self.webView{
            
            let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);"
            w.evaluateJavaScript(javascript, completionHandler: nil)
            
            
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }
    }
    
}
