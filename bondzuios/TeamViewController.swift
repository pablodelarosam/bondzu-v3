//
//  TeamViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class TeamViewController: UIViewController {
    @IBOutlet weak var animalEffectView: EffectBackgroundView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.animalEffectView.setImageArray(Constantes.animalArrayImages)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Equipo", comment: "")
    }

}
