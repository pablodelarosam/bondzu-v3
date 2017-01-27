//
//  StoreViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 13/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit
import Parse
//opensource frameworks used: SwiftyDrop, Just, Hokusai, TaskQueue

//WebView Controller for specials sections: store, bondzu girls, events, and wallpapers
class StoreViewController: UIViewController, UIWebViewDelegate {

    //the user
    var user = Usuario(object: PFUser.current()!, imageLoaderObserver: nil)
    //the webview outlet
    @IBOutlet weak var myWebView: UIWebView!
    //the website's string
    var urlString: String?
    //the URL
    var url: URL?
    //the name of the view selected on the previous ViewController
    var nameOfView: String?
    //boolean to determine if the user selected the wallpaper's option
    var wallpapersSelected: Bool?
    //boolean to determine if the user selected the store's option
    var storeIsSelected: Bool?
    //session token to be retrieved
    var sessionToken = ""
    
    
    //localized strings
    let failed = NSLocalizedString("Failed", comment: "")
    let success = NSLocalizedString("Success", comment: "")
    let save = NSLocalizedString("Save", comment: "")
    let saving = NSLocalizedString("Saving...", comment: "")
    
    //stuff for saving an image
    let kTouchJavaScriptString: String = "document.ontouchstart=function(event){x=event.targetTouches[0].clientX;y=event.targetTouches[0].clientY;document.location=\"myweb:touch:start:\"+x+\":\"+y;};document.ontouchmove=function(event){x=event.targetTouches[0].clientX;y=event.targetTouches[0].clientY;document.location=\"myweb:touch:move:\"+x+\":\"+y;};document.ontouchcancel=function(event){document.location=\"myweb:touch:cancel\";};document.ontouchend=function(event){document.location=\"myweb:touch:end\";};"
    var _gesState: Int = 0, _imgURL: String = "", _timer: Timer = Timer()

    
    //back and forward buttons for webview navigation
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let puser = PFUser.current()!
        sessionToken = puser.sessionToken!
        
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
    
    //HTTP request to send the user's data
    func sendPOST(_ url: URL){
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "user=\(user.originalObject.objectId!)&token=\(sessionToken)".data(using: String.Encoding.utf8)
        myWebView.loadRequest(request as URLRequest)
    }
    
    // basic webView code with unwrapping optional URL
    func loadWebPage(){
        if let urlString = urlString{
            url = URL (string: urlString)
        }else{
            url = URL(string: "https://www.google.com.mx/")
        }
        //send post request
        if let storeIsSelected = storeIsSelected {
            if storeIsSelected == true{
              sendPOST(url!)
            }else{
                let requestObj = URLRequest(url: url!)
                myWebView.loadRequest(requestObj)
            }
        }
    }
    
    // MARK: - UIWebView delegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        myWebView.stringByEvaluatingJavaScript(from: kTouchJavaScriptString)
    }
    
    //sets the title of the view in the navigation bar according to the site selected
    override func viewDidAppear(_ animated: Bool) {
        if let nameOfView = nameOfView {
            self.navigationController?.navigationBar.topItem?.title = NSLocalizedString(nameOfView, comment: "")
        }else{
            self.navigationController?.navigationBar.topItem?.title = NSLocalizedString("Especiales", comment: "")
        }
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
        super.viewDidAppear(animated)
    }
    
    //changes the status bar's font and icons to white
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    
    //methods to enable navigation in the websites displayed
    @IBAction func backWasPressed(_ sender: AnyObject) {
        myWebView.goBack()
    }
    
    @IBAction func forwardWasPressed(_ sender: AnyObject) {
        myWebView.goForward()
    }
    
    //webView delegate function that handles saving the image with javascript code
    func webView(_ webView: UIWebView, shouldStartLoadWith _request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
      let m = "about:blank"
        var a:String = String(describing: _request.url)
        if (a == m ) {
            return false
        }
        
        let requestString: String = (_request.url?.absoluteString)!
        var components: [String] = requestString.components(separatedBy: ":")
        if (components.count > 1 && components[0] == "myweb") {
            if (components[1] == "touch") {
                if (components[2] == "start") {
                    _gesState = 1
                    let ptX: Float = Float(components[3])!
                    let ptY: Float = Float(components[4])!
                    let js: String = "document.elementFromPoint(\(ptX), \(ptY)).tagName"
                    let tagName: String = myWebView.stringByEvaluatingJavaScript(from: js)!
                    _imgURL = ""
                    if (tagName == "IMG") {
                        _imgURL = myWebView.stringByEvaluatingJavaScript(from: "document.elementFromPoint(\(ptX), \(ptY)).src")!
                        _timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(StoreViewController.handleLongTouch), userInfo: nil, repeats: false)
                    }
                } else {
                    if (components[2] == "move") {
                        self._gesState = 2
                    } else {
                        if (components[2] == "end") {
                            _timer.invalidate()
                            self._timer = Timer()
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
            buttonColor: UIColor.white,
            cancelButtonColor: UIColor(hexString: "FFA844")!, //light orange
            fontColor: UIColor.black
        )
        hokusai.fontName = "Helvetica"
        hokusai.addButton(save) {
            Drop.down(self.saving, state: DropState.color(Constantes.COLOR_NARANJA_NAVBAR))
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
        if let url = URL(string: self._imgURL) {
            if let data = try? Data(contentsOf: url) {
                if (UIImage(data: data) != nil) {
                    let image = UIImage(data: data)
                    UIImageWriteToSavedPhotosAlbum(image!, self, #selector(StoreViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    return
                }
            }
        }
        Drop.down(failed, state: DropState.error)
    }
    
    //image!!
    func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        if didFinishSavingWithError != nil {
            Drop.down(failed, state: DropState.error)
            return
        }
        Drop.down(success, state: DropState.success)
    }
    
    //message to the user, how to download image
    func popAlert(){
        let ac = UIAlertController(title: NSLocalizedString("Save them!", comment: ""), message: NSLocalizedString("To download a wallpaper, press and hold on any thumbnail", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
            _ -> Void in
            ac.dismiss(animated: true, completion: nil)
        }))
        self.present(ac, animated: true, completion: nil)
    }

    
}
