//
//  UserPlanPurchaseManager.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 2/18/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit
import WebKit


class UserPlanPurchaseManager: WKWebView, WKNavigationDelegate{
    
    let user : Usuario
    
    init(user : Usuario, insets : UIEdgeInsets, webPage : NSURL = planPurchaseURL! , desiredType : UserType){
        self.user = user
        super.init(frame: CGRectZero, configuration: WKWebViewConfiguration())
        self.autoresizingMask = [ .FlexibleHeight, .FlexibleWidth ]
        self.autoresizesSubviews = true
        self.scrollView.contentInset = insets
        let request = NSURLRequest(URL: webPage)
        self.navigationDelegate = self
        
    }

    
}
