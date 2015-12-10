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


class SignUpViewController : UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, WKNavigationDelegate, LoginManagerResultDelegate {
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                let lm = LoginManager()
                lm.registerUser(self.name.text!, email: self.mail.text!, password: self.pass.text!, image: nil, delegate: self)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        else{
            let lm = LoginManager()
            lm.registerUser(self.name.text!, email: self.mail.text!, password: self.pass.text!, image: self.profile.image , delegate: self)
        }
    }
    
    @IBAction func registerFacebook(sender: AnyObject) {
        loading = LoadingView(view: self.view)
        let lm = LoginManager()
        lm.loginWithFacebook(self, finishingDelegate: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        mail.text = ""
        pass.text = ""
        name.text = ""
        hasImage = false
        profile.image = UIImage(named: "profile_pic")
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        if let w = self.webView{
            
            let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);"
            w.evaluateJavaScript(javascript, completionHandler: nil)
            
            
            activityView.stopAnimating()
            activityView.removeFromSuperview()
        }
    }
    
    
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
    
}