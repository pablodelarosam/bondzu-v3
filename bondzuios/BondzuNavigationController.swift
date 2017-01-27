//
//  BondzuNavigationBar.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 1/11/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

open class BondzuNavigationController : UINavigationController {
    
    var user : Usuario?{
        didSet{
            if user != nil && user!.hasLoadedPriority{
                self.refreshBarTintColor()
            }
            user?.appendTypeLoadingObserver({
                
                [weak self]
                (user, _) -> (Bool) in
                
                if self == nil{
                    return false
                }
                
                if user == self?.user{
                    self?.refreshBarTintColor()
                }
                
                return true
            })
        
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshBarTintColor()
    }
    
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    open override var shouldAutorotate : Bool {
        return visibleViewController!.shouldAutorotate
    }
    
    open override var childViewControllerForStatusBarHidden : UIViewController? {
        return self.topViewController
    }
    
    open override var childViewControllerForStatusBarStyle : UIViewController? {
        return self.topViewController
    }
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        refreshBarTintColor()
    }
    
    open func refreshBarTintColor(){
        if self.user != nil && user!.hasLoadedPriority{
            self.navigationBar.barTintColor = user!.type!.color
        }
        else{
            self.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        }
    }
    
    override func logoutUser() {
        self.user = nil
        super.logoutUser()
    }
    
}
