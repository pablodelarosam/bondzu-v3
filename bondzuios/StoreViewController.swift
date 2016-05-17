//
//  StoreViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class StoreViewController: UIViewController {

    @IBOutlet weak var myWebView: UIWebView!
    var urlString: String?
    var url: NSURL?
    var nameOfView: String?
    
//    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "longPressed:")
//    self.view.addGestureRecognizer(longPressRecognizer)
//    
//    func longPressed(sender: UILongPressGestureRecognizer)
//    {
//        print("longpressed")
//    }

    
    @IBAction func longPressed(sender: AnyObject) {
        if sender.state == UIGestureRecognizerState.Began
        {
            let alertController = UIAlertController(title: nil, message:
                "Long-Press Gesture Detected", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Your webView code goes here
        if let urlString = urlString{
            url = NSURL (string: urlString)
            print(urlString)
        }else{
            url = NSURL(string: "https://www.google.com.mx/")
        }
        
        let requestObj = NSURLRequest(URL: url!)
        myWebView.loadRequest(requestObj)
    }
    
    override func viewDidAppear(animated: Bool) {
        if let nameOfView = nameOfView {
            self.navigationController?.navigationBar.topItem?.title = NSLocalizedString(nameOfView, comment: "")
        }else{
            self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Especiales", comment: "")
        }
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
