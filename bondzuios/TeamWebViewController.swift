//
//  TeamWebViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 20/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class TeamWebViewController: UIViewController {

    @IBOutlet weak var myWebView: UIWebView!
    let stringCreditosWeb = NSLocalizedString("creditosWeb", comment: "")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL (string: stringCreditosWeb)
        let requestObj = NSURLRequest(URL: url!)
        myWebView.loadRequest(requestObj)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Team", comment: "")
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
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
