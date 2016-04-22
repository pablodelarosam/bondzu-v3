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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL (string: "http://bondzu.com/tienda/")
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
        //esto sirve para que no este la lupa de buscar arriba a la derecha!
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
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
