//
//  TabsViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit

/**
 This class is responsable of managing the tabs of any animal.
 This class will also provide a blocking view in case the user don't have acces to it.
 
 All sub view controllers will be responsable of updating the blocking view when new information is available
 
 */
class TabsViewController: UITabBarController, UserBlockingHelperDelegate {
    
    ///The animal that must be passed to all sub view controllers. This item MUST be set by the presenter view controller
    var animal: AnimalV2!
    
    ///The user that must be passed to all sub view controllers. This item MUST be set by the presenter view controller.
    var user : Usuario!
    
    ///The blocking view that will be set if the uer don't have access to the animal.
    private var tabBlockingView : UserBlockingHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tabBar.tintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.tabBlockingView = UserBlockingHelper(controller: self.navigationController!, view: self.view, requiredType: nil, user: user, delegate: self)
        
        if user.hasLoadedPriority{
            tabBar.tintColor = user.type!.color
        }
        user.appendTypeLoadingObserver({
            [weak self]
            (_, type) -> (Bool) in
            
            if self == nil{
                return false
            }
            
            if let type = type{
                self?.tabBar.tintColor = type.color
                
            }
            
            return true
        })
        
        
        for viewController in viewControllers!{
            
            if let vc = viewController as? AboutViewController
            {
                vc.animalID = self.animal.objectId
                vc.blockingHelper = self.tabBlockingView
                vc.user = self.user
            }
            else if let vc = viewController as? CommunityViewController
            {
                vc.animalID = self.animal.objectId
            }
            else if let vc = viewController as? GalleryViewController
            {
                vc.animalId = self.animal.objectId
                vc.blockingHelper = self.tabBlockingView

            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    //MARK: User blocking delegate
    
    /**
    Part of a protocol implementation.
    This is going to be called when the blocking view has failed.
    This method will go back to the previous controller.
    */
    func userBlockingHelperFailed() {
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong, please try again later", comment: ""), preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {
            _ -> Void in
            self.navigationController?.popViewControllerAnimated(true)
            self.tabBlockingView = nil
        }))
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    /**
     Part of protocol implementation.
     This is going to be called when the blocking view has finished its work.
     
     - parameter result: A boolean telling the dlegate if the user has or not permission to see the resource. According to the parameter an action will be taken.
     
     */
    func userBlockingHelperWillDismiss(result: Bool) {
        if(!result){
            self.navigationController?.popViewControllerAnimated(true)
        }
        self.tabBlockingView = nil

    }
    
}


