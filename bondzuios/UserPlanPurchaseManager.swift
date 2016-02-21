//
//  UserPlanPurchaseManager.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 2/18/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

/**
 This protocol wont notify if the user has updated its account as thats *Usuario* responsibility
 */
@objc protocol UserPlanPurchaseManagerProtocol{
    
    /**
     This method will be called when the view is about to be dismissed. When this method is called it means that the view will remove itself from the view hierarchy.
     */
    func webPurchasePlanPagePageWillDismiss()
    
    /**
     This method indicates that the web view failed loading.
     */
    func webPurchasePlanPageDidFail()
}

/**
 This class is the main entry point forleting the user purchase a new plan. 
 
 **The main rule for this class is not to dismiss it manually. Instead you should call *cancel* and the view will remove itself from the hierarchy.**
 
 If you dont follow that rule, memory leaks may occur.
 */
class UserPlanPurchaseManager: UIWebView, UIWebViewDelegate{
    
    /// The *Usuario* instance that is being updating
    private let user : Usuario
    
    /// The delegate that is going to be called about the class status.
    private weak var planPurchaseDelegate : UserPlanPurchaseManagerProtocol?
    
    /**
     Default class initializer for the class. This class asks for every piece of information it needs for performing the http request. The request is built and sent auomatically.
     
     - parameter user: The user that wants to be upgraded
     - parameter insets: When the view has other views that need to be taken in mid you should specify the bounds here 
     - parameter delegate: The instance that wants to take de notifications
     
     */
    init(user : Usuario, insets : UIEdgeInsets, desiredType : UserType, delegate : UserPlanPurchaseManagerProtocol){
        self.user = user
        let webPage : NSURL = planPurchaseURL!
        super.init(frame: CGRectZero)
        self.autoresizingMask = [ .FlexibleHeight, .FlexibleWidth ]
        self.autoresizesSubviews = true
        self.scrollView.contentInset = insets
        let request = NSMutableURLRequest(URL: webPage)
        request.HTTPMethod = "POST"
        request.HTTPBody = "user=\(user.originalObject.objectId!)&type=\(desiredType.originalObject.objectId!)".dataUsingEncoding(NSUTF8StringEncoding)
        
        self.planPurchaseDelegate = delegate
        self.delegate = self
        self.loadRequest(request)
    }

    /**
     Please do not use with this class or the app will crash
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
     This method is going to be called when the purchase is done or canceled.
     
     Other objects may also call this object if they want to stop the process or if they need to dismiss the view or the view controller
     */
    func cancel(){
        self.stopLoading()
        self.removeFromSuperview()
        self.planPurchaseDelegate?.webPurchasePlanPagePageWillDismiss()
        self.user.refreshUserType()
        done()
    }

    /**
     Called when the operation could not be completed
     
     **Dont call directly**
     
     */
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        self.planPurchaseDelegate?.webPurchasePlanPageDidFail()
        cancel()
        done()

    }

    /**
     This method reset the delagte of its superclass to nil to avoid memory leaks
     */
    private func done(){
        self.delegate = nil
    }
    
    /**
     Protocol implementation.
     This method checks when the user is moving from one page to another and is used to check when the purchase is complete.
     */
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        guard let u = request.URL , let p = u.path else{
            return false
        }
        
        if p.containsString("appDone"){
            self.user.refreshUserType()
        }
        
        return true
    }

}
