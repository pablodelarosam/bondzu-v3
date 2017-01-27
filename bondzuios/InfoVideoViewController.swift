//
//  InfoVideoViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 23/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class InfoVideoViewController: UIViewController, YTPlayerViewDelegate {

    @IBOutlet weak var animalViewEffect: EffectBackgroundView!
    
    let videoId = "Z0XCFs1Rbz8"

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var player: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.delegate = self
        animalViewEffect.setImageArray(Constantes.animalArrayImages)
        player.load(withVideoId: videoId)

    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
            self.activityIndicator.stopAnimating()        
    }
    //make status bar white
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    

    //navigation controller setup
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Video"
        self.navigationController!.navigationBar.topItem!.rightBarButtonItem = nil
    }

}
