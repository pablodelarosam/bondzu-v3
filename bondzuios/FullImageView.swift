//
//  FullImageView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/9/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController, UINavigationControllerDelegate {
    
    var background = UIImage(){
        didSet{
            if let f = fullImageView{
                f.image = background
            }
        }
    }
    
    
    private var fullImageView : FullImageView?
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        let view = FullImageView()
        view.bgImage.image = background
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    private class FullImageView : UIView{

        
        var imageview = UIImageView()
        var bgImage = UIImageView()

        private var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        private var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        
        init(){
            super.init(frame: UIScreen.mainScreen().bounds)
            load()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            load()
        }
        
        
        //TODO Version 2 Agregar un dismisal al bajar el dedo
        
        func load(){
            
            if let w = UIApplication.sharedApplication().keyWindow{
                w.addSubview(self)
                self.frame = CGRect(x: 0, y: 0, width: w.bounds.width, height: w.bounds.height)
            }
            
            
            bgImage.contentMode = .ScaleAspectFill
            
            addSubview(bgImage)
            addSubview(blur)
            addSubview(activityIndicatorView)
            activityIndicatorView.color = UIColor.orangeColor()
        }
        
        
        var image : UIImage?{
            get{
                return imageview.image
            }
            set{
                imageview.image = newValue
                setNeedsLayout()
            }
        }
        
        
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.frame = superview!.frame
            bgImage.frame = frame
            blur.frame = frame
            
            if imageview.image != nil{
                activityIndicatorView.stopAnimating()
            }
            else{
                activityIndicatorView.startAnimating()
                activityIndicatorView.frame = CGRect(x: frame.size.width/2 - 100, y: frame.size.height/2 - 100, width: 200, height: 200)
            }
        }

    }
}
