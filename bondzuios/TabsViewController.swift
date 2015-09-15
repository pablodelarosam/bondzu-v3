//
//  TabsViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit

class TabsViewController: UITabBarController {
    var animal: AnimalV2!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for viewController in viewControllers!
        {
            if let vc = viewController as? AboutViewController
            {
                vc.animalID = self.animal.objectId
            }
            
            if let vc = viewController as? GiftsViewController
            {
                vc.animalId = self.animal.objectId
            }
        }
        // Do any additional setup after loading the view.
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
