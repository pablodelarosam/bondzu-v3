//
//  BondzuNavigationBar.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 1/11/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

public class BondzuNavigationController : UINavigationController {
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshBarTintColor()
    }
    
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    public override func shouldAutorotate() -> Bool {
        return visibleViewController!.shouldAutorotate()
    }
    
    public override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return self.topViewController
    }
    
    public override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return self.topViewController
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshBarTintColor()
    }
    
    public func refreshBarTintColor(){
        if let user = PFUser.currentUser(){
            self.navigationBar.barTintColor = UIColor.greenColor()
        }
        else{
            self.navigationBar.barTintColor = Constantes.COLOR_NARANJA_NAVBAR
        }
    }
    
}
