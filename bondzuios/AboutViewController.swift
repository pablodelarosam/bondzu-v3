//
//  AboutViewController.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "About"
        let live = UIBarButtonItem(title: "Cams", style: .Plain, target: self, action: "showCams:")
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = live
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let liveStreamVC = segue.destinationViewController as! VideoViewController
        
        //TESTING
        liveStreamVC.animalId = "uoG4QimJN9"
    }
    
    @IBAction func ShowCameras(sender: AnyObject) {        self.performSegueWithIdentifier("liveStreamSegue", sender: self)
    }
    
    func showCams(sender: UIBarButtonItem)
    {
        self.performSegueWithIdentifier("liveStreamSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
