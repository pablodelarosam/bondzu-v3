//
//  VideoCapsulasViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/8/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Arichivo Localizado

import UIKit
import youtube_ios_player_helper

class VideoCapsulasViewController: UIViewController, YTPlayerViewDelegate, UserBlockingHelperDelegate, CapsuleLoadingDelegate {

    var capsule : Capsule!
    var user : Usuario!
    
    @IBOutlet var c1: NSLayoutConstraint!
    @IBOutlet var c2: NSLayoutConstraint!
    @IBOutlet var c3: NSLayoutConstraint!
    @IBOutlet var c4: NSLayoutConstraint!

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var player : YTPlayerView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    private var blockingHelper : UserBlockingHelper?
    
    var requiredToolbar = false
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if capsule.hasLoadedPriority{
            blockingHelper = UserBlockingHelper(controller: self, view: self.view, requiredType: capsule.requiredPriority!.priority, user: user, delegate: self)
        }
        else{
            capsule.delegate = self
            blockingHelper = UserBlockingHelper(controller: self, view: self.view, requiredType: nil, user: user, delegate: self)
        }
        
        player.loadWithVideoId(capsule.videoID[0])
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enteredFullScreen", name: UIWindowDidBecomeVisibleNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "exitedFullScreen", name: UIWindowDidBecomeHiddenNotification, object: nil)
        
        videoTitle.text = capsule.title[0]
        videoDescription.text = capsule.videoDescription[0]
        
        player.delegate = self
        
        navigationItem.title = NSLocalizedString("Video", comment: "")
        toolbar.hidden = !requiredToolbar

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func done(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
   
    func enteredFullScreen(){
        dispatch_async(dispatch_get_main_queue()){
            self.view.removeConstraints([self.c1,self.c2,self.c3,self.c4])
            self.view.setNeedsUpdateConstraints()
        }
    }

    func exitedFullScreen(){
        dispatch_async(dispatch_get_main_queue()){
            self.view.addConstraints([self.c1,self.c2,self.c3,self.c4])
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        dispatch_async(dispatch_get_main_queue()){
            self.loadingIndicator.stopAnimating()
            playerView.hidden = false

        }
        
    }
    
    func requireToolBar(required : Bool){
        if let t = toolbar{
            t.hidden = !required
        }
        else{
            requiredToolbar = required
        }
    }

    //MARK: Capsule delegate
    
    func capsuleDidFailLoading(capsule: Capsule) {}
    
    func capsuleDidFinishLoading(capsule: Capsule) {}
    
    func capsuleDidLoadRequiredType(capsule: Capsule) {
        self.blockingHelper?.setRequiredPriority(capsule.requiredPriority!.priority)
    }
    
    func capsuleDidFailLoadingRequiredType(capsule: Capsule) {
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {
            _ -> Void in
            self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            self.blockingHelper = nil
        }))
        self.presentViewController(ac, animated: true, completion: nil)

    }
    
    //MARK: Blocking view delegate
    

    //TODO: Empty implementation
    func userBlockingHelperFailed() {
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wront, please try again later", comment: ""), preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {
            _ -> Void in
            
            if let pvc =  self.presentingViewController{
                pvc.dismissViewControllerAnimated(true, completion: nil)
            }
            else{
                self.navigationController?.popViewControllerAnimated(true)
            }
            
            self.blockingHelper = nil
        }))
        self.presentViewController(ac, animated: true, completion: nil)

    }
    
    func userBlockingHelperWillDismiss(result: Bool) {
        if !result{
            if let pvc =  self.presentingViewController{
                pvc.dismissViewControllerAnimated(true, completion: nil)
            }
            else{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
        else{
            self.blockingHelper = nil
        }
        
    }
}
