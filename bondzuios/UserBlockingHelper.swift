//
//  UserBlockingHelper.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 1/15/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

@objc
protocol UserBlockingHelperDelegate{
    /**
     This method will be called when the controller is not longer necesary
     
     - parameter result: The result of the operation. If true is passed it means that the user has acces to it. Otherwise the entire controller should be removed
     */
    func userBlockingHelperWillDismiss(_ result : Bool)
    func userBlockingHelperFailed()
}

/**
 This class is provided to block views that are restricted due to user type.
 
 This class is going to provide a view that will attach to another superview and will add transparency to it. 
 
 This class will provide methods to load the view and dismiss it in the case where it was not necesary or when the user has upgrade its account
 
 */
class UserBlockingHelper: NSObject, UserPlanPurchaseManagerProtocol{
    
    /// The controller in which the web view may be presented
    fileprivate var controller : UIViewController
    ///The view that is going to be blocked
    fileprivate var overlapingView : UIView
    /// The tyoe that the user require for the view to be unlocked
    fileprivate var requiredType : Int? = nil
    /// The user that is going to be checked / upgraded
    fileprivate var user : Usuario

    /// The instance of the blocking view that is going to be used
    fileprivate var view : BlockingView = BlockingView()
    
    /// The delegate that is going to inform about the blocking view status
    fileprivate weak var delegate : UserBlockingHelperDelegate?
    
    /// The web view that is going to be used for upgrading the user
    fileprivate var webView : UserPlanPurchaseManager?
    
    /// The actual purchasable user type
    fileprivate var userTypeInstance : UserType?
    
    
    /**
     Default initialization for the class 
     - parameter controller: The viewcontroller to present a modal controller in case that the user wants to upgrade
     - parameter view: The view that is going to be blocked
     - parameter requiredType: The type that the user requires. If the type has no been loaded yet a nil must be passed to this view so its loading, then it can be modified with setRequiredPriority
     - parameter user: The user that wants to be compared
     - parameter delegate: The delegate to callback with notifications. This will create a weak reference but the parameter is required
     */
    init(controller : UIViewController, view : UIView, requiredType : Int?, user : Usuario , delegate : UserBlockingHelperDelegate) {
        self.controller = controller
        self.overlapingView = view
        self.user = user
        self.delegate = delegate
        super.init()
        self.view.helper = self
        self.requiredType = requiredType
        
        view.addSubview(self.view)

        if user.hasLoadedPriority{
            attempToLoadBlockingView()
        }
        
        user.appendTypeLoadingObserver({
            [weak self]
            (_, type) -> (Bool) in
            
            if self == nil{ return false }
            
            if type != nil{
               self?.attempToLoadBlockingView()
            }
            else{
                delegate.userBlockingHelperFailed()
                self?.view.removeFromSuperview()
            }
            return true
        })
        
    }
    
    
    /**
     This function provides a convenient way to tell the blocking helper when the required priority has been loaded
     This will only change the value if no other value has been set
     
     - parameter priority: The user required priority.
     - returns: A boolean that tells if the operation succeded or not
     
     */
    func setRequiredPriority(_ priority : Int) -> Bool{
        
        if requiredType != nil{
            return false
        }
        
        self.requiredType = priority
        attempToLoadBlockingView()
        return true
    }
    
    /**
     This method is going to be trigered when the user wants to update its profile.
     
     */
    func purchasePlan(){
        view.button.isEnabled = false
        webView = UserPlanPurchaseManager(user: self.user, insets: UIEdgeInsets.zero, desiredType: userTypeInstance!, delegate: self)
        webView?.frame = self.view.frame
        webView?.frame.origin.y = webView!.frame.height
        
        if let vc =  self.controller.navigationController{
            let h = vc.navigationBar.frame.height + 15
            webView?.scrollView.contentInset = UIEdgeInsets(top: h, left: 0, bottom: 0, right: 0)
        }
        else if let vc = self.controller as? UINavigationController{
            let h = vc.navigationBar.frame.height + 15
            webView?.scrollView.contentInset = UIEdgeInsets(top: h, left: 0, bottom: 0, right: 0)
        }
        
        self.view.addSubview(webView!)
        UIView.animate(withDuration: 1, animations: {
            self.webView!.frame.origin.y = self.webView!.frame.origin.y - self.webView!.frame.size.height
        })
    }
    
    /**
     This method needs to be called then the controller is going to be dismissed but its work is not yet done or when the user wants to have it dismissed.
    
     **The result of calling this method wil result in a notification to the delegate about failure**
     */
    func dismissController(){
        self.webView?.cancel()
        delegate?.userBlockingHelperWillDismiss(false)
    }
    
    
    /**
     This function is the main port entry for checking if everithing is ok and notifyng to the delegate.
     Call this function when anything has been loaded such a user type or required prority
     */
    fileprivate func attempToLoadBlockingView(){
        
        guard user.hasLoadedPriority && self.requiredType != nil else{
            return
        }
        
        
        if user.type!.priority >= requiredType!{
            
            //This means he user upgraded
            if let v = webView{
                v.cancel()
                self.webView = nil
            }
            
            self.delegate?.userBlockingHelperWillDismiss(true)
            self.view.removeFromSuperview()
            return
        }
        else{
            if let v = webView{
                v.cancel()
                self.view.button.isEnabled = true
                self.webView = nil
            }
        }
        
        user.userNeededTypeForRequestedPermission(requiredType!) {
            [weak self]
            type in
            if let type = type{
                self?.userTypeInstance = type
                self?.view.setUserRequiredTitle(type.name, color: type.color)
            }
            else{
                self?.delegate?.userBlockingHelperFailed()
            }
        }
    }
    
    //MARK: UserPlanPurchaseManagerProtocol
    
    /**
     Implementation of protocol.
     
     This method is going to be called when the web view is about to be dismissed. 
     
     This class won't do anything when this happens as it does not give any extrea information
     */
    func webPurchasePlanPagePageWillDismiss() {
        webView = nil
    }
    
    /**
     This method is an implementation of a protocol. 
     
     Is going to be called when there is an error in the purchase process loading.
     
     Its going to inform the user about that
     */
    func webPurchasePlanPageDidFail() {
        self.webView = nil
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "Something went wront, please try again later", preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK" , comment: ""), style: .default, handler: {
            _ in
            self.delegate?.userBlockingHelperWillDismiss(false)
        }))
        self.controller.present(ac, animated: true, completion: nil)
    }
    
    /**
     Only avoids memory leaks of web view
     */
    deinit{
        webView?.cancel()
    }
}

/**
 This class is not intended to be called by external classes.
 
 Only UserBlockingHelper is authorized to use it
 
 This is not a reusable class.
 */
class BlockingView : UIView{
    
    /// This is the view that is set when the user type is not loaded yet
    fileprivate let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    /// The top label indicating the "To see me"
    fileprivate let topLabel = UILabel()
    /// The center label indicating "you need to be"
    fileprivate let centerLabel = UILabel()
    /// The label indicating the usertype
    fileprivate let bottonLabel = UILabel()
    /// The purchase button
    fileprivate let button = UIButton(type: UIButtonType.roundedRect)
    /// The logo that appears at the bottom of the screen
    fileprivate let finalLogo = UIImageView(image: UIImage(named: "whitePaw")!)
    /// Indictes if the view is still loading
    fileprivate var loading = true
    
    /// A stack view that includes the above mentioned views
    fileprivate var stackView = UIStackView()
    
    /// As this is a private and not reusable class, there is an instance to the only possible caller. Its weak to avoid a circular reference
    weak var helper : UserBlockingHelper?
    
    /**
     Called when the view is ready to display content.
     This method shows the view components
     */
    fileprivate func stopLoading(){
        loading = false
        stackView.isHidden = false
        activityIndicatorView.stopAnimating()
    }
    
    /**
     This method should be called by the owner to let this class know the information that it should display. 
     
      - parameter title: The title of the type that the user needs
      - parameter color: The color that represents the type
     */
    func setUserRequiredTitle(_ title : String, color: UIColor){
        bottonLabel.textColor = color
        bottonLabel.text = title
        self.stopLoading()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    /**
     This method is provided to load the view components. 
     As this properties are going to be set in every constructor, its taken to another method to avoid duplication.
     */
    fileprivate func load(){
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        stackView.isHidden = true
        
        self.addSubview(activityIndicatorView)
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(centerLabel)
        stackView.addArrangedSubview(bottonLabel)
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(finalLogo)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        self.addSubview(stackView)
        
        topLabel.textColor = UIColor.white
        centerLabel.textColor = UIColor.white
        bottonLabel.textColor = UIColor.white
        
        topLabel.font = topLabel.font.withSize(20)
        centerLabel.font = centerLabel.font.withSize(20)
        bottonLabel.font = bottonLabel.font.withSize(25)
        
        
        self.button.addTarget(self, action: #selector(BlockingView.buttonActioned), for: UIControlEvents.touchUpInside)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(BlockingView.screenTaped))
        self.addGestureRecognizer(gestureRecognizer)
        
        topLabel.text = NSLocalizedString("In order to watch me", comment: "")
        centerLabel.text = NSLocalizedString("You need to be", comment: "")
        button.setTitle(NSLocalizedString("  Start now  ", comment: ""), for: UIControlState())
        
        button.backgroundColor = UIColor.orange
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel!.font = button.titleLabel!.font.withSize(20)
        button.sizeToFit()
        Imagenes.redondeaVista(button, radio: 10)
    }
    
    /**
     This method is going to be called when the button of purchase is actioned. 
     It indicates the desired action to its helper.
     */
    @IBAction func buttonActioned(){
        helper?.purchasePlan()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame.origin = CGPoint.zero
        self.frame.size = self.superview!.bounds.size
        activityIndicatorView.frame.origin = CGPoint.originForCenteringView(activityIndicatorView, inView: self)
        stackView.frame.size = CGSize(width: self.bounds.size.width, height: self.bounds.size.height / 2)
        stackView.frame.origin = CGPoint.originForCenteringView(stackView, inView: self)
    }
    
    /**
     This method is called when anything but the button is tapped.
     This tap means that the user don't want to see the controll anymore so the helper is notified about this.
     */
    @IBAction func screenTaped(){
        helper?.dismissController()
    }

}
