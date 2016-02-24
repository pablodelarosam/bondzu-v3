//
//  LoginManager.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/9/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4


///As the login and sign up methods are asynchronus, this protocol is the callback for login events
@objc protocol LoginManagerResultDelegate{
    /**
     Called when the login was succesfull
     
     - parameter user: The loged in user
     */
    func loginManagerDidLogin(user : PFUser)
    /**
     Called when the sign up was succesfull
     
     - parameter user: The loged in user
     */
    func loginManagerDidRegister(user : PFUser)
    
    /**
     Called when the login or sign up was unsuccesfull. In a comming soon api the error will be reported.
     //TODO: ^
     */
    func loginManagerDidFailed()
    
    /**
     Called when the user canceled the operation
     */
    func loginManagerDidCanceled()
}


///The errors that can happen during login
enum LoginError : ErrorType{
    /// The database handler produced an error
    case ParseError
    ///The internet conection produced a login error
    case InternetError
    ///In case of sign up the user already exists
    case UserAlreadyExistsError
    ///In case of sign up the stripe framework failed to provide a stripe_key
    case StripeError
    ///In case of sign up the password was unsafe
    case TooShortPassword
    ///The password is not correct
    case InvalidPassword
}


///This class provides the start point for loging and signing up users to the database
class LoginManager{
    
    /// The delegate that is going to receive the result of login or sign up
    weak var delegate : LoginManagerResultDelegate?
    
    /**
     This function attemp to login a user throught facebook
     
     If the user is not registered this function also rgisters it
    
     This function is intended to be called by external classes

     - parameter presentingController: Ignored if imageLoaderObserver is not null. It tell wether the image will be loaded or not

     - returns: A string in case the operation succeds. Nil otherwise.
     */
    func loginWithFacebook(presentingController : UIViewController, finishingDelegate : LoginManagerResultDelegate){
        let fbPermission = ["user_about_me","email"]
        let login = FBSDKLoginManager()
        login.loginBehavior = .Native
        
        if let at = FBSDKAccessToken.currentAccessToken(){
            PFFacebookUtils.logInInBackgroundWithAccessToken(at, block: finishFacebookRegister)
            return
        }
        
        login.logInWithReadPermissions(fbPermission, fromViewController: presentingController){
            (result, error) -> Void in
            if error != nil{
                dispatch_async(dispatch_get_main_queue()){
                    print("Error login in facebook \(error)")
                    finishingDelegate.loginManagerDidFailed()
                }
            }
            else if result.isCancelled{
                dispatch_async(dispatch_get_main_queue()){
                    finishingDelegate.loginManagerDidCanceled()
                }
            }
            else{
                self.delegate = finishingDelegate
                PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken(), block: self.finishFacebookRegister)
            }
        }
    }
    
    /**
     This function is intended to be called by Parse - Facebook SDK.
     
     This value is not intended to use by other classes nor this class directly
     
     - parameter user: The created PFUser
     
     - returns: A string with the id. A LoginError is thrown otherwiswe.
     */
    func finishFacebookRegister (user : PFUser?, error : NSError?){
        if error != nil{
            print(error)
            self.delegate?.loginManagerDidFailed()
        }
        else if user!.isNew{
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email,picture.width(100).height(100)"]).startWithCompletionHandler({
                (connection, dic, error) -> Void in
                if let dictionary = dic as? Dictionary<String, AnyObject>{

                    let user = user!
                    guard  let name = dictionary["name"] as? String, let mail = dictionary["email"] as? String, let dictionaryUnwraped = (dictionary["picture"] as? Dictionary<String,AnyObject>), let dictionaryData = dictionaryUnwraped["data"] as? Dictionary<String,AnyObject>, let picture = dictionaryData["url"] as? String else{
                        self.attempToDeleteUserAndNotifyDelegate(user)
                        return
                    }
                    
                    user[TableUserColumnNames.Name.rawValue] = name
                    user.password = "\(random())"
                    user[TableUserColumnNames.Mail.rawValue] = mail
                    user[TableUserColumnNames.PhotoURL.rawValue] = picture
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
                        
                        do{ //Get token and save user
                            let id = try self.getToken(user[TableUserColumnNames.Mail.rawValue] as? String)
                            user[TableUserColumnNames.StripeID.rawValue] = id
                            try user.save()
                            dispatch_async(dispatch_get_main_queue()){
                                self.delegate?.loginManagerDidRegister(user)
                            }
                        }
                        catch{
                            self.attempToDeleteUserAndNotifyDelegate(user)
                        }
                    }
                }
                else{
                    self.attempToDeleteUserAndNotifyDelegate(user)
                }
            })
        }
        else{
            dispatch_async(dispatch_get_main_queue()){
                self.delegate?.loginManagerDidLogin(user!)
            }
        }
    }

    /**
     This function attemp to get a token for the user created.
     
     This value is not intended to use by other classes
     
     ### Call in background ###
     
     - parameter mail: The mail of the user that wants a stripe ID
     
     - returns: A string with the id. A LoginError is thrown otherwiswe.
     */
    func getToken(mail : String?) throws -> String{
        
        if(NSThread.isMainThread()){
            mainThreadWarning()
        }
        
        let dic : [String: String] = [
            "email" : "\( mail != nil ? mail : "mail undisclosed")",
            "description" : "Cuenta creada para \( mail != nil ? mail : "mail undisclosed")"
        ]
        
        do{
            let object : AnyObject? = try PFCloud.callFunction(PFCloudFunctionNames.CreateCustomer.rawValue, withParameters: dic)
            if let data = object?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
               
                guard let jsonDictionary = jsonDict else{
                    throw LoginError.StripeError
                }

                let key = "id";
                guard let id = jsonDictionary[key] as? String else{
                    throw LoginError.StripeError
                }

                return id
            }
        }
        catch{
            throw LoginError.InternetError
        }
        
        throw LoginError.StripeError
    }
    
    /**
     This function attemp to delete a user after a error.
     
     This function is also responsable for calling the delegate
     
     ### Call in background ###
     
     - parameter user: The user to delete
     
     */
    func attempToDeleteUserAndNotifyDelegate(user : PFUser?){
        
        do{
            if let user = user{
                try user.delete()
            }
        }
        catch{}
        
        dispatch_async(dispatch_get_main_queue()){
            self.delegate?.loginManagerDidFailed()
        }
    }
    
    /**
     This function attemp to register a user. The information should be validated before arriving to the function
     
     - parameter name: The name of the user to register
     - parameter email: The email of the user to register
     - parameter password: The password of the user to register
     - parameter image: The profile image of the user to register. If nil no image is going to be registered.
     - parameter delegate: The delegate to call with the result

     */
    func registerUser(name : String, email : String, password : String, image : UIImage?, delegate : LoginManagerResultDelegate){
        
        if password.characters.count < 6{
            delegate.loginManagerDidFailed()
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            do{
                var error : NSError? = nil
                
                let query = PFQuery(className: TableNames.User.rawValue)
                query.whereKey(TableUserColumnNames.UserName.rawValue, equalTo: email.lowercaseString)
                let elements = query.countObjects( &error )
                
                if error != nil || elements != 0{
                    dispatch_async(dispatch_get_main_queue()){
                        delegate.loginManagerDidFailed()
                    }
                    return
                }

                let user = PFUser()
                user.username = email.lowercaseString
                user.password = password
                user.email = email.lowercaseString
                user[TableUserColumnNames.Name.rawValue] = name
                
                if let image = image{
                    user[TableUserColumnNames.PhotoFile.rawValue] = PFFile(data: UIImagePNGRepresentation(image)!)
                }
                
                let token = try self.getToken(email)
                user[TableUserColumnNames.StripeID.rawValue] = token
                try user.signUp()
                
                dispatch_async(dispatch_get_main_queue()){
                    delegate.loginManagerDidRegister(user)
                }
                
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    delegate.loginManagerDidFailed()
                }
            }
        }
    }
    
    /**
     This function attemp to login a user.
     
     - parameter username: The users username
     - parameter password: The password of the user to login
     - parameter delegate: The delegate to call with the result
     
     */
    func login( username : String , password : String, finishingDelegate : LoginManagerResultDelegate ){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)){
            
            do{
                try PFUser.logInWithUsername(username, password: password)
                dispatch_async(dispatch_get_main_queue()){
                    if let user = PFUser.currentUser(){ finishingDelegate.loginManagerDidLogin(user) }
                    else{ finishingDelegate.loginManagerDidFailed() }
                }
            }
            catch{
                dispatch_async(dispatch_get_main_queue()){
                    finishingDelegate.loginManagerDidFailed()
                }
            }
            
        }
    }
    
 
}
