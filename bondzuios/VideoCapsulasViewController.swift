//
//  VideoCapsulasViewController.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 10/8/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoCapsulasViewController: UIViewController, YTPlayerViewDelegate {

    var capsule : Capsule!
    
    @IBOutlet var c1: NSLayoutConstraint!
    @IBOutlet var c2: NSLayoutConstraint!
    @IBOutlet var c3: NSLayoutConstraint!
    @IBOutlet var c4: NSLayoutConstraint!

    
    @IBOutlet weak var player : YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.loadWithVideoId("zBjrcNL8pGo")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enteredFullScreen", name: UIWindowDidBecomeVisibleNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "exitedFullScreen", name: UIWindowDidBecomeHiddenNotification, object: nil)

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

}
