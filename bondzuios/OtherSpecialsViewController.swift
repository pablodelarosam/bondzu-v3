//
//  OtherSpecialsViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 23/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class OtherSpecialsViewController: UIViewController {

    @IBOutlet weak var animalViewEffect: EffectBackgroundView!
    
    @IBOutlet weak var otherspecialsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         animalViewEffect.setImageArray(Constantes.animalArrayImages)
        otherspecialsLabel.text = NSLocalizedString("Content not currently available", comment: "empty table view sections")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Specials", comment: "")
    }
   

}
