//
//  AnimalEffectBackgroundView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 1/28/16.
//  Copyright © 2016 Bondzu. All rights reserved.
//

import UIKit


class EffectBackgroundView: UIView {

    
    fileprivate let blurContainer = UIView()
    fileprivate let backgroundImage = UIImageView()
    
    fileprivate var backgroundImages = [UIImage]()

    fileprivate let animationDuration: TimeInterval = 0.9
    fileprivate let switchingInterval: TimeInterval = 5
    
    fileprivate var animating = false
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light)) as UIVisualEffectView
    
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
    
    
    fileprivate func animateBackgroundImageView(){
        
        if !animating{
            return
        }
        
        CATransaction.begin()
        
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            let delay = DispatchTime.now() + Double(Int64(self.switchingInterval * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                
                self.animateBackgroundImageView()
            }
        }
        let transition = CATransition()
        transition.type = kCATransitionFade
        self.backgroundImage.layer.add(transition, forKey: kCATransition)
       
        let x: Int = Int(arc4random())
    let Y = Int( x  % self.backgroundImages.count )
      
        self.backgroundImage.image = self.backgroundImages[Y]
        
        CATransaction.commit()
    
    }
    
    
    func setImageArray( _ imagesToDisplay : [UIImage]){
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
