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
    
    
    fileprivate var blockingHelper : UserBlockingHelper?
    
    var requiredToolbar = false
    
    //timer for blocking basic users, not yet implemented, has to be started in ViewDidLoad
    var timer = Timer()
    //time in seconds that the video will play before stopping
    var videoTime = 15.0
    //timer for checking seeking in video player
    var timer2 = Timer()

    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //if species == humans .. load a special video
        if capsule.animalId == "661WX90t3V"{
            player.load(withVideoId: "zA2AnVwTMKY")
            videoTitle.text = NSLocalizedString("Humans", comment: "")
            videoDescription.text = NSLocalizedString("You are the solution", comment: "")
        }else{
            player.load(withVideoId: capsule.videoID[0])
            videoTitle.text = capsule.title[0]
            videoDescription.text = capsule.videoDescription[0]
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoCapsulasViewController.enteredFullScreen), name: NSNotification.Name.UIWindowDidBecomeVisible, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(VideoCapsulasViewController.exitedFullScreen), name: NSNotification.Name.UIWindowDidBecomeHidden, object: nil)
        
        player.delegate = self
        
        navigationItem.title = NSLocalizedString("Video", comment: "")
        toolbar.isHidden = !requiredToolbar
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func done(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
   
    func enteredFullScreen(){
        DispatchQueue.main.async{
            self.view.removeConstraints([self.c1,self.c2,self.c3,self.c4])
            self.view.setNeedsUpdateConstraints()
        }
    }

    func exitedFullScreen(){
        DispatchQueue.main.async{
            self.view.addConstraints([self.c1,self.c2,self.c3,self.c4])
            self.view.setNeedsUpdateConstraints()
        }
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView!) {
        DispatchQueue.main.async{
            self.loadingIndicator.stopAnimating()
            playerView.isHidden = false

        }
        
    }
    
    // when playing video, if the user is not permitted to watch the video, only then start the timer
    func playerView(_ playerView: YTPlayerView!, didChangeTo state: YTPlayerState) {
        switch (state) {
            case YTPlayerState.playing:
                print("PLAYER IS PLAYING HAHA \n")
                //unwrap
                if let userType = user.type, let capsulePriority = capsule.requiredPriority {
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
    
    func requireToolBar(_ required : Bool){
        if let t = toolbar{
            t.isHidden = !required
        }
        else{
            requiredToolbar = required
        }
    }

    //MARK: Capsule delegate
    
    func capsuleDidFailLoading(_ capsule: Capsule) {}
    
    func capsuleDidFinishLoading(_ capsule: Capsule) {}
    
    func capsuleDidLoadRequiredType(_ capsule: Capsule) {
        self.blockingHelper?.setRequiredPriority(capsule.requiredPriority!.priority)
    }
    
    func capsuleDidFailLoadingRequiredType(_ capsule: Capsule) {
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong, please try again later", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
            _ -> Void in
            self.presentingViewController!.dismiss(animated: true, completion: nil)
            self.blockingHelper = nil
        }))
        self.present(ac, animated: true, completion: nil)

    }
    
    //MARK: Blocking view delegate
    

    func userBlockingHelperFailed() {
        let ac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Something went wrong, please try again later", comment: ""), preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: {
            _ -> Void in
            
            if let pvc =  self.presentingViewController{
                pvc.dismiss(animated: true, completion: nil)
            }
            else{
                self.navigationController?.popViewController(animated: true)
            }
            
            self.blockingHelper = nil
        }))
        self.present(ac, animated: true, completion: nil)

    }
    
    func userBlockingHelperWillDismiss(_ result: Bool) {
        if !result{
            if let pvc =  self.presentingViewController{
                pvc.dismiss(animated: true, completion: nil)
            }
            else{
                self.navigationController?.popViewController(animated: true)
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
        timer = Timer.scheduledTimer(timeInterval: videoTime, target: self, selector: #selector(VideoCapsulasViewController.stopVideo), userInfo: nil, repeats: false)
        timer2 = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(VideoCapsulasViewController.checkSeek), userInfo: nil, repeats: true)
    }
    
    //this method is called when the time limit for basic users is up
    func stopVideo(){
            let end = Float(player.duration())
            player.stopVideo()
            player.seek(toSeconds: end, allowSeekAhead: false)
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
