//
//  StoreViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

//opensource frameworks used: SwiftyDrop, Just, Hokusai, TaskQueue

//WebView Controller for specials sections: store, bondzu girls, events, and wallpapers
class StoreViewController: UIViewController, UIWebViewDelegate {

    //the webview outlet
    @IBOutlet weak var myWebView: UIWebView!
    //the website's string
    var urlString: String?
    //the URL
    var url: NSURL?
    //the name of the view selected on the previous ViewController
    var nameOfView: String?
    //boolean to determine if the user selected the wallpaper's option
    var wallpapersSelected: Bool?
    
    //localized strings
    let failed = NSLocalizedString("Failed", comment: "")
    let success = NSLocalizedString("Success", comment: "")
    let save = NSLocalizedString("Save", comment: "")
    let saving = NSLocalizedString("Saving...", comment: "")
    
    //stuff for saving an image
    let kTouchJavaScriptString: String = "document.ontouchstart=function(event){x=event.targetTouches[0].clientX;y=event.targetTouches[0].clientY;document.location=\"myweb:touch:start:\"+x+\":\"+y;};document.ontouchmove=function(event){x=event.targetTouches[0].clientX;y=event.targetTouches[0].clientY;document.location=\"myweb:touch:move:\"+x+\":\"+y;};document.ontouchcancel=function(event){document.location=\"myweb:touch:cancel\";};document.ontouchend=function(event){document.location=\"myweb:touch:end\";};"
    var _gesState: Int = 0, _imgURL: String = "", _timer: NSTimer = NSTimer()

    
    //back and forward buttons for webview navigation
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myWebView.delegate = self
        loadWebPage()
      
        let queue = TaskQueue()
        queue.tasks +=! {
            self.loadWebPage()
        }
        queue.run()
        
        if let wallpapersSelected = wallpapersSelected{
            if wallpapersSelected == true { popAlert() }
        }
        
        
        //set the arrows of back and forward to orange
        self.backButton.tintColor = Constantes.COLOR_NARANJA_NAVBAR
        self.forwardButton.tintColor = Constantes.COLOR_NARANJA_NAVBAR
        
    }
    
    
    
    // basic webView code with unwrapping optional URL
    func loadWebPage(){
        if let urlString = urlString{
            url = NSURL (string: urlString)
            print(urlString)
        }else{
            url = NSURL(string: "https://www.google.com.mx/")
        }
        let requestObj = NSURLRequest(URL: url!)
        myWebView.loadRequest(requestObj)
    }
    
    
    
    // MARK: - UIWebView delegate
    func webViewDidFinishLoad(webView: UIWebView) {
        myWebView.stringByEvaluatingJavaScriptFromString(kTouchJavaScriptString)
    }
    
    //sets the title of the view in the navigation bar according to the site selected
    override func viewDidAppear(animated: Bool) {
        if let nameOfView = nameOfView {
            self.navigationController?.navigationBar.topItem?.title = NSLocalizedString(nameOfView, comment: "")
        }else{
            self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Especiales", comment: "")
        }
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    //changes the status bar's font and icons to white
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    //methods to enable navigation in the websites displayed
    @IBAction func backWasPressed(sender: AnyObject) {
        myWebView.goBack()
    }
    
    @IBAction func forwardWasPressed(sender: AnyObject) {
        myWebView.goForward()
    }
    
    //webView delegate function that handles saving the image with javascript code
    func webView(webView: UIWebView, shouldStartLoadWithRequest _request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (_request.URL! == "about:blank") {
            return false
        }
        
        let requestString: String = (_request.URL?.absoluteString)!
        var components: [String] = requestString.componentsSeparatedByString(":")
        if (components.count > 1 && components[0] == "myweb") {
            if (components[1] == "touch") {
                if (components[2] == "start") {
                    _gesState = 1
                    let ptX: Float = Float(components[3])!
                    let ptY: Float = Float(components[4])!
                    let js: String = "document.elementFromPoint(\(ptX), \(ptY)).tagName"
                    let tagName: String = myWebView.stringByEvaluatingJavaScriptFromString(js)!
                    _imgURL = ""
                    if (tagName == "IMG") {
                        _imgURL = myWebView.stringByEvaluatingJavaScriptFromString("document.elementFromPoint(\(ptX), \(ptY)).src")!
                        _timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "handleLongTouch", userInfo: nil, repeats: false)
                    }
                } else {
                    if (components[2] == "move") {
                        self._gesState = 2
                    } else {
                        if (components[2] == "end") {
                            _timer.invalidate()
                            self._timer = NSTimer()
                            self._gesState = 4
                        }
                    }
                }
            }
            return false
        }
        return true
    }
    
    //hokusai is the menu with options to save the image
    func handleLongTouch() {
        let hokusai = Hokusai()
        hokusai.colors = HOKColors(
            backGroundColor: Constantes.COLOR_NARANJA_NAVBAR, //always orange
            buttonColor: UIColor.whiteColor(),
            cancelButtonColor: UIColor(hexString: "FFA844")!, //light orange
            fontColor: UIColor.blackColor()
        )
        hokusai.fontName = "Helvetica"
        hokusai.addButton(save) {
            Drop.down(self.saving, state: DropState.Color(Constantes.COLOR_NARANJA_NAVBAR))
            let queue = TaskQueue()
            queue.tasks +=! {
                self.saveImage()
            }
            queue.run()
        }
        hokusai.show()
    }
    
    //save the image!!
    func saveImage () {
        if let url = NSURL(string: self._imgURL) {
            if let data = NSData(contentsOfURL: url) {
                if (UIImage(data: data) != nil) {
                    let image = UIImage(data: data)
                    UIImageWriteToSavedPhotosAlbum(image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
                    return
                }
            }
        }
        Drop.down(failed, state: DropState.Error)
    }
    
    //image!!
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        if didFinishSavingWithError != nil {
            Drop.down(failed, state: DropState.Error)
            return
        }
        Drop.down(success, state: DropState.Success)
    }
    
    //message to the user, how to download image
    func popAlert(){
        let ac = UIAlertController(title: NSLocalizedString("Save them!", comment: ""), message: NSLocalizedString("To download a wallpaper, press and hold on any thumbnail", comment: ""), preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {
            _ -> Void in
            ac.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(ac, animated: true, completion: nil)
    }

    
}
