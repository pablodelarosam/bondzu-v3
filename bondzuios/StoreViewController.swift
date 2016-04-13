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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Your webView code goes here
        let url = NSURL (string: "http://bondzu.com/tienda/")
        let requestObj = NSURLRequest(URL: url!)
        myWebView.loadRequest(requestObj)
    }
}
