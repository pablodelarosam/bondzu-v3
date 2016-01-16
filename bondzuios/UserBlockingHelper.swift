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
    func userBlockingHelperWillDismiss()
    func userBlockingHelperFailed()
    func userDidUpgradeAndViewWillDismiss()
}

/**
 This class is provided to block views that are restricted due to user type.
 
 This class is going to provide a view that will attach to another superview and will add transparency to it. 
 
 This class will provide methods to load the view and dismiss it in the case where it was not necesary or when the user has upgrade its account
 
 */
class UserBlockingHelper: NSObject {
    
    
    private var controller : UIViewController
    private var overlapingView : UIView
    private var requiredType : Int
    private var user : Usuario
    
    
    
    private weak var delegate : UserBlockingHelperDelegate?
    
    /**
     Default initialization for the class 
     - parameter controller: The viewcontroller to present a modal controller in case that the user wants to upgrade
     - parameter view: The view that is going to be blocked
     - parameter requiredType: The type that the user requires. If the type has no been loaded yet a zero must be passed to this view so its loading, then it can be modified with updateUserRequestedPriority
     - parameter user: The user that wants to be compared
     - parameter delegate: The delegate to callback with notifications. This will create a weak reference but the parameter is required
     */
    init( controller : UIViewController, view : UIView, requiredType : Int, user : Usuario , delegate : UserBlockingHelperDelegate) {
        self.controller = controller
        self.overlapingView = view
        self .requiredType = requiredType
        self.user = user
        self.delegate = delegate
    }
    
    
    
}

/**
 This class is not intended to be called by external classes. 
 
 Only UserBlockingHelper is authorized to use it
 
 */
class BlockingView : UIView{
    
    /// This is the view that is set when the user type is not loaded yet
    private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    private let topLabel = UILabel()
    private let centerLabel = UILabel()
    private let bottonLabel = UILabel()
    private let button = UIButton()
    private let finalLogo = UIImageView(image: UIImage(named: "whitePaw")!)
    private var loading = true
    
    func load(){
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.addSubview(activityIndicatorView)
        self.addSubview(topLabel)
        self.addSubview(centerLabel)
        self.addSubview(bottonLabel)
        self.addSubview(button)
        self.addSubview(finalLogo)
    }
    
    override func layoutSubviews() {
        
    }
    
}