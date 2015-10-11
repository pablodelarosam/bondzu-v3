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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.loadWithVideoId(capsule.videoID[0])
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enteredFullScreen", name: UIWindowDidBecomeVisibleNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "exitedFullScreen", name: UIWindowDidBecomeHiddenNotification, object: nil)
        
        videoTitle.text = capsule.title[0]
        videoDescription.text = capsule.videoDescription[0]
        
        player.delegate = self
        
        navigationItem.title = NSLocalizedString("Video", comment: "")

    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func enteredFullScreen(){
        view.removeConstraints([c1,c2,c3,c4])
        view.setNeedsUpdateConstraints()
    }

    func exitedFullScreen(){
        view.addConstraints([c1,c2,c3,c4])
        view.setNeedsUpdateConstraints()

    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        self.loadingIndicator.stopAnimating()
        playerView.hidden = false
    }
}
