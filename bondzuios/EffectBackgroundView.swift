//
//  AnimalEffectBackgroundView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 1/28/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit

class EffectBackgroundView: UIView {

    
    private let blurContainer = UIView()
    private let backgroundImage = UIImageView()
    
    private var backgroundImages = [UIImage]()

    private let animationDuration: NSTimeInterval = 0.9
    private let switchingInterval: NSTimeInterval = 5
    
    private var animating = false
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light)) as UIVisualEffectView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        load()
    }
    
    func load(){
        self.blurContainer.addSubview(visualEffectView)
        self.blurContainer.alpha = 0.92;
        
        self.addSubview(backgroundImage)
        self.addSubview(blurContainer)
    }
    
    
    private func animateBackgroundImageView(){
        
        if !animating{
            return
        }
        
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(self.switchingInterval * NSTimeInterval(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue()) {
                
                self.animateBackgroundImageView()
            }
        }
        let transition = CATransition()
        transition.type = kCATransitionFade
        self.backgroundImage.layer.addAnimation(transition, forKey: kCATransition)
        self.backgroundImage.image = self.backgroundImages[random() % self.backgroundImages.count]
        
        CATransaction.commit()
    
    }
    
    
    func setImageArray( imagesToDisplay : [UIImage]){
        if imagesToDisplay.count == 0{
            self.backgroundImage.image = nil
            self.backgroundImages = imagesToDisplay
            animating = false
        }
        else if imagesToDisplay.count == 1{
            self.backgroundImage.image = imagesToDisplay[0]
            self.backgroundImages = imagesToDisplay
            animating = false
        }
        else{
            self.backgroundImages = imagesToDisplay
            animating = true
            self.animateBackgroundImageView()
        }
    }
    
    
    override func layoutSubviews() {
        self.blurContainer.frame = self.bounds
        self.backgroundImage.frame = self.bounds
        self.visualEffectView.frame = self.bounds
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
