//
//  NoCamerasViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 14/09/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

protocol NoCamerasDismissedProtocol
{
    func dismiss()
}

class NoCamerasViewController: UIViewController{

    @IBOutlet weak var backgroundImage: UIImageView!
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
    @IBOutlet weak var blur: UIView!
    var dismissProtocol: NoCamerasDismissedProtocol!
    var backImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blur.addSubview(visualEffectView)
        self.blur.alpha = 0.95
        
        self.backgroundImage.image = backImage
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doneClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.dismissProtocol.dismiss();
    }
    
    override func viewDidLayoutSubviews() {
        visualEffectView.frame.size = CGSize(width: self.view.frame.width , height: self.view.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
