//
//  NoCamerasViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 14/09/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit

protocol NoCamerasDismissedProtocol
{
    func dismiss()
}

class NoCamerasViewController: UIViewController{

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var infoLabel: UITextView!
    
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark)) as UIVisualEffectView
    @IBOutlet weak var blur: UIView!
    var dismissProtocol: NoCamerasDismissedProtocol!
    var backImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blur.addSubview(visualEffectView)
        self.blur.alpha = 0.95
        
        self.backgroundImage.image = backImage
        
        infoLabel.text = NSLocalizedString("I need time for myself Just like everyone else. Please come back later", comment: "")
        // Do any additional setup after loading the view.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
