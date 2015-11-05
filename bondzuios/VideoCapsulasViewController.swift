//
//  VideoCapsulasViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/8/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Arichivo Localizado

import UIKit
import youtube_ios_player_helper

class VideoCapsulasViewController: UIViewController, YTPlayerViewDelegate {

    var capsule : Capsule!
    
    @IBOutlet var c1: NSLayoutConstraint!
    @IBOutlet var c2: NSLayoutConstraint!
    @IBOutlet var c3: NSLayoutConstraint!
    @IBOutlet var c4: NSLayoutConstraint!

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var player : YTPlayerView!
    @IBOutlet weak var videoTitle: UILabel!
    @IBOutlet weak var videoDescription: UILabel!
    
    @IBOutlet weak var toolbar: UIToolbar!
    
    var requiredToolbar = false
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}
