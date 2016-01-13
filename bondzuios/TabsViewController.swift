//
//  TabsViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import UIKit

class TabsViewController: UITabBarController {
    
    var animal: AnimalV2!
    var user : Usuario!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = Constantes.COLOR_NARANJA_NAVBAR
        
        if user.hasLoadedPriority{
            tabBar.tintColor = user.type!.color
        }
        else{
            user.appendTypeLoadingObserver({
                (_, type) -> () in
                if let type = type{
                    self.tabBar.tintColor = type.color
                }
            })
        }
        
        for viewController in viewControllers!
        {
            if let vc = viewController as? AboutViewController
            {
                vc.animalID = self.animal.objectId
                vc.user = self.user
            }
            else if let vc = viewController as? CommunityViewController
            {
                vc.animalID = self.animal.objectId
            }
            else if let vc = viewController as? GiftsViewController
            {
                vc.animalId = self.animal.objectId
                vc.user = self.user
            }
            
            if let vc = viewController as? GalleryViewController
            {
                vc.animalId = self.animal.objectId
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
