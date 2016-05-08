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
