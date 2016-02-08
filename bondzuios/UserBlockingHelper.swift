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
    func userBlockingHelperWillDismiss(result : Bool)
    func userBlockingHelperFailed()
}

/**
 This class is provided to block views that are restricted due to user type.
 
 This class is going to provide a view that will attach to another superview and will add transparency to it. 
 
 This class will provide methods to load the view and dismiss it in the case where it was not necesary or when the user has upgrade its account
 
 */
class UserBlockingHelper: NSObject {
    
    
    private var controller : UIViewController
    private var overlapingView : UIView
    private var requiredType : Int? = nil
    private var user : Usuario
    
    private var view : BlockingView = BlockingView()
    
    private weak var delegate : UserBlockingHelperDelegate?
    
    /**
     Default initialization for the class 
     - parameter controller: The viewcontroller to present a modal controller in case that the user wants to upgrade
     - parameter view: The view that is going to be blocked
     - parameter requiredType: The type that the user requires. If the type has no been loaded yet a nil must be passed to this view so its loading, then it can be modified with setRequiredPriority
     - parameter user: The user that wants to be compared
     - parameter delegate: The delegate to callback with notifications. This will create a weak reference but the parameter is required
     */
    init( controller : UIViewController, view : UIView, requiredType : Int?, user : Usuario , delegate : UserBlockingHelperDelegate) {
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
    func setRequiredPriority(priority : Int) -> Bool{
        
        if requiredType != nil{
            return false
        }
        
        self.requiredType = priority
        attempToLoadBlockingView()
        return true
    }
    
    //TODO On web service
    func purchasePlan(){}
    
    func dismissController(){
        delegate?.userBlockingHelperWillDismiss(false)
    }
    
    
    /**
     This function is the main port entry for checking if everithing is ok and notifyng to the delegate.
     Call this function when anything has been loaded such a user type or required prority
     */
    private func attempToLoadBlockingView(){
        
        guard user.hasLoadedPriority && self.requiredType != nil else{
            return
        }
        
        if user.type!.priority >= requiredType!{
            self.delegate?.userBlockingHelperWillDismiss(true)
            self.view.removeFromSuperview()
            return
        }
        
        user.userNeededTypeForRequestedPermission(requiredType!) {
            type -> () in
            if let type = type{
                self.view.setUserRequiredTitle(type.name, color: type.color)
            }
            else{
                self.delegate?.userBlockingHelperFailed()
            }
        }
    }
}

/**
 This class is not intended to be called by external classes.
 
 Only UserBlockingHelper is authorized to use it
 
 This is not a reusable class.
 */
class BlockingView : UIView{
    
    /// This is the view that is set when the user type is not loaded yet
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    private let topLabel = UILabel()
    private let centerLabel = UILabel()
    private let bottonLabel = UILabel()
    private let button = UIButton(type: UIButtonType.RoundedRect)
    private let finalLogo = UIImageView(image: UIImage(named: "whitePaw")!)
    private var loading = true
    
    private var stackView = UIStackView()
    
    weak var helper : UserBlockingHelper?
    
    private func stopLoading(){
        loading = false
        stackView.hidden = false
        activityIndicatorView.stopAnimating()
    }
    
    func setUserRequiredTitle(title : String, color: UIColor){
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
    
    func load(){
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.hidesWhenStopped = true
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        
        stackView.hidden = true
        
        self.addSubview(activityIndicatorView)
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(centerLabel)
        stackView.addArrangedSubview(bottonLabel)
        stackView.addArrangedSubview(button)
        stackView.addArrangedSubview(finalLogo)
        stackView.axis = .Vertical
        stackView.alignment = .Center
        stackView.distribution = .EqualSpacing
        self.addSubview(stackView)
        
        topLabel.textColor = UIColor.whiteColor()
        centerLabel.textColor = UIColor.whiteColor()
        bottonLabel.textColor = UIColor.whiteColor()
        
        topLabel.font = topLabel.font.fontWithSize(20)
        centerLabel.font = centerLabel.font.fontWithSize(20)
        bottonLabel.font = bottonLabel.font.fontWithSize(25)
        
        
        self.button.addTarget(self, action: "buttonActioned", forControlEvents: UIControlEvents.TouchDragInside)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "screenTaped")
        self.addGestureRecognizer(gestureRecognizer)
        
        topLabel.text = NSLocalizedString("In order to watch me", comment: "")
        centerLabel.text = NSLocalizedString("You need to be", comment: "")
        button.setTitle(NSLocalizedString("  Start now  ", comment: ""), forState: UIControlState.Normal)
        
        button.backgroundColor = UIColor.orangeColor()
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel!.font = button.titleLabel!.font.fontWithSize(20)
        button.sizeToFit()
        Imagenes.redondeaVista(button, radio: 10)
    }
    
    @IBAction func buttonActioned(){
        helper?.purchasePlan()
    }
    
    override func layoutSubviews() {
        self.frame.origin = CGPointZero
        self.frame.size = self.superview!.bounds.size
        activityIndicatorView.frame.origin = CGPoint.originForCenteringView(activityIndicatorView, inView: self)
        stackView.frame.size = CGSize(width: self.bounds.size.width, height: self.bounds.size.height / 2)
        stackView.frame.origin = CGPoint.originForCenteringView(stackView, inView: self)
    }
    
    @IBAction func screenTaped(){
        helper?.dismissController()
    }
    
    
    
}