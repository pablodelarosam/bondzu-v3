//
//  InfoVideoViewController.swift
//  bondzuios
//
//  Created by Daniela Becerra on 23/04/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class InfoVideoViewController: UIViewController {

    @IBOutlet weak var animalViewEffect: EffectBackgroundView!
    
    let videoId = "Z0XCFs1Rbz8"

    @IBOutlet weak var player: YTPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animalViewEffect.setImageArray(Constantes.animalArrayImages)
        player.loadWithVideoId(videoId)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Video"
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
