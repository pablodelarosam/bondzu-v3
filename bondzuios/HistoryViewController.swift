//
//  HistoryViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet weak var animalViewEffect: EffectBackgroundView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.animalViewEffect.setImageArray(Constantes.animalArrayImages)

    
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Historia", comment: "")
    }

}
