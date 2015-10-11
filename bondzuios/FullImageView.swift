//
//  FullImageView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/9/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

class FullImageViewController: UIViewController, UINavigationControllerDelegate {
    
    private var fullImageView : FullImageView?
    
    
    func loadImage(image : UIImage){
        fullImageView?.image = image
    }
    
    func loadParseImage(image : PFFile){
        image.getDataInBackgroundWithBlock(){
            data , error in
            
            guard error == nil , let imageData = data else{
                print("Error al descargar imagen")
                self.dismiss()
                return
            }
            
            self.fullImageView?.image = UIImage(data: imageData)
        }
    }
    
    var background = UIImage(){
        didSet{
            if let f = fullImageView{
                f.image = background
            }
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        view = UIImageView(image: captureScreen())
        setNeedsStatusBarAppearanceUpdate()
        fullImageView = FullImageView()
        fullImageView!.bgImage.image = background
        fullImageView!.delegate = self
    }
    
    func dismiss(){
        fullImageView!.delegate = nil
        fullImageView?.delegate = nil
        
        UIView.animateWithDuration(0.5,
            animations: {
                fullImageView?.frame.origin = CGPoint(x: 0, y: fullImageView!.frame.size.height)
            },
            completion: {
                _ in
                self.fullImageView?.removeFromSuperview()
                self.dismissViewControllerAnimated(false, completion: nil)
                
            }
        )
        
    }
    
    
    
    class FullImageView : UIView{

        var button = UIButton()
        
        var delegate : FullImageViewController?{
            didSet{
                if let d = delegate{
                    button.addTarget(d, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
        }
        
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
        
        func dismiss(){
            delegate?.dismiss()
            removeFromSuperview()
        }
        
        func load(){
            
            if let w = UIApplication.sharedApplication().keyWindow{
                w.addSubview(self)
                self.frame = CGRect(x: 0, y: 0, width: w.bounds.width, height: w.bounds.height)
            }
            
            button.setTitle(NSLocalizedString("Done", comment: ""), forState: UIControlState.Normal)
        
            
            activityIndicatorView.hidesWhenStopped = true
            bgImage.contentMode = .ScaleAspectFill
            imageview.contentMode = .ScaleAspectFit
            
            addSubview(bgImage)
            addSubview(blur)
            addSubview(activityIndicatorView)
            addSubview(button)
            addSubview(imageview)
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
                
                let fw = frame.width
                let fh = frame.height - 30
                let iw = imageview.image!.size.width
                let ih = imageview.image!.size.width
                
                if(iw < fw && ih < fh){
                    imageview.frame = CGRect(x: fw/2 - iw/2, y: fh/2 - ih/2, width: iw, height: ih)
                }
                else{
                    let dw = iw - fw
                    let dh = ih - fh
                    
                    if dw < dh{
                        
                        let nih = fh
                        let niw = fh * iw / ih
                        
                        imageview.frame = CGRect(x: fw/2 - niw/2, y: fh/2 - nih/2, width: niw, height: nih)
                        
                    }
                    else{
                        
                        let niw = fw
                        let nih = fw * ih / iw
                        
                        imageview.frame = CGRect(x: fw/2 - niw/2, y: fh/2 - nih/2, width: niw, height: nih)
                    }
                }
                
            }
            else{
                activityIndicatorView.startAnimating()
                activityIndicatorView.frame = CGRect(x: frame.size.width/2 - 100, y: frame.size.height/2 - 100, width: 200, height: 200)
            }
            
            button.sizeToFit()
            button.frame.origin = CGPoint(x: 20, y: 20)
        }

    }
}
