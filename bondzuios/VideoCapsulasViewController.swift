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
    
    //timer for blocking basic users, not yet implemented, has to be started in ViewDidLoad
    var timer = NSTimer()
    //time in seconds that the video will play before stopping
    var videoTime = 15.0
    //timer for checking seeking in video player
    var timer2 = NSTimer()

    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //if species == humans .. load a special video
        if capsule.animalId == "661WX90t3V"{
            player.loadWithVideoId("zA2AnVwTMKY")
            videoTitle.text = NSLocalizedString("Humans", comment: "")
            videoDescription.text = NSLocalizedString("You are the solution", comment: "")
        }else{
            player.loadWithVideoId(capsule.videoID[0])
            videoTitle.text = capsule.title[0]
            videoDescription.text = capsule.videoDescription[0]
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enteredFullScreen", name: UIWindowDidBecomeVisibleNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "exitedFullScreen", name: UIWindowDidBecomeHiddenNotification, object: nil)
        
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
    
    // when playing video, if the user is not permitted to watch the video, only then start the timer
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        switch (state) {
            case YTPlayerState.Playing:
                print("PLAYER IS PLAYING HAHA \n")
                //unwrap
                if let userType = user.type, capsulePriority = capsule.requiredPriority {
                        //check condition
                        if capsulePriority.priority > userType.priority {
                            startTimer()
                        }
                }
//                if playerView.currentTime()>5.0 {
//                    
//                }
                break
            default:
            break
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
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong, please try again later", comment: ""), preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: {
            _ -> Void in
            self.presentingViewController!.dismissViewControllerAnimated(true, completion: nil)
            self.blockingHelper = nil
        }))
        self.presentViewController(ac, animated: true, completion: nil)

    }
    
    //MARK: Blocking view delegate
    

    func userBlockingHelperFailed() {
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong, please try again later", comment: ""), preferredStyle: .Alert)
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
    
    //to block users that dont have the level required
    func blockUser(){
                if capsule.hasLoadedPriority{
                    blockingHelper = UserBlockingHelper(controller: self, view: self.view, requiredType: capsule.requiredPriority!.priority, user: user, delegate: self)
                }
                else{
                    capsule.delegate = self
                    blockingHelper = UserBlockingHelper(controller: self, view: self.view, requiredType: nil, user: user, delegate: self)
                }
        
    }
    
    
    
    //timer stuff
    func startTimer(){
        print("timer started with time to live: \(videoTime)")
        timer = NSTimer.scheduledTimerWithTimeInterval(videoTime, target: self, selector: "stopVideo", userInfo: nil, repeats: false)
        timer2 = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "checkSeek", userInfo: nil, repeats: true)
    }
    
    //this method is called when the time limit for basic users is up
    func stopVideo(){
            let end = Float(player.duration())
            player.stopVideo()
            player.seekToSeconds(end, allowSeekAhead: false)
            blockUser()
            timer.invalidate()
            timer2.invalidate()
    }
    
    func checkSeek(){
        if player.currentTime()>15.0 {
            stopVideo()
        }
    }
    
}
