//
//  FullImageView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 9/9/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//  Archivo Localizado

import UIKit
import Parse

class FullImageViewController: UIViewController, UINavigationControllerDelegate{
    
    fileprivate weak var fullImageView : FullImageView?
    
    
    func loadImage(_ image : UIImage){
        fullImageView?.image = image
    }
    
    func loadParseImage(_ image : PFFile){
        image.getDataInBackground(){
            data , error in
            
            guard error == nil , let imageData = data else{
                print("Error al descargar imagen")
                self.dismiss()
                return
            }
            
            self.fullImageView?.image = UIImage(data: imageData)
        }
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        
        self.modalTransitionStyle = .flipHorizontal
        setNeedsStatusBarAppearanceUpdate()
        view = UIImageView(image: captureScreen())
        view.isUserInteractionEnabled = true
        let fiv =  FullImageView()
        fullImageView = fiv
        fullImageView!.delegate = self
        self.view.addSubview(fullImageView!)
    }
    
    func dismiss(){
        fullImageView!.delegate = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    
    class FullImageView : UIView{

        var button = UIButton()
        var saveButton = UIButton()
        
        var delegate : FullImageViewController?
        
        
        var imageview = UIImageView()
        var bgImage = UIImageView()

        fileprivate var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        fileprivate var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        
        init(){
            super.init(frame: UIScreen.main.bounds)
            load()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            load()
        }
        
        
        //localized strings
        let failed = NSLocalizedString("Failed", comment: "")
        let success = NSLocalizedString("Success", comment: "")
        let save = NSLocalizedString("Save", comment: "")
        let saving = NSLocalizedString("Saving...", comment: "")
        
        //TODO Version 2 Agregar un dismisal al bajar el dedo
        
        func dismiss(){
            print("DISMISEANDO");
            delegate?.dismiss()
        }
        
        
        func load(){
            
            /*if let w = UIApplication.sharedApplication().keyWindow{
                w.addSubview(self)
                self.frame = CGRect(x: 0, y: 0, width: w.bounds.width, height: w.bounds.height)
            }*/
            
            button.setTitle(NSLocalizedString("Done", comment: ""), for: UIControlState())
            button.addTarget(self, action: #selector(FullImageView.dismiss), for: UIControlEvents.touchUpInside)
            
            saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: UIControlState())
            saveButton.addTarget(self, action: #selector(FullImageView.saveImage), for: UIControlEvents.touchUpInside)
            
            activityIndicatorView.hidesWhenStopped = true
            bgImage.contentMode = .scaleAspectFill
            imageview.contentMode = .scaleAspectFit
            
            addSubview(bgImage)
            addSubview(blur)
            addSubview(activityIndicatorView)
            addSubview(button)
            addSubview(saveButton)
            addSubview(imageview)
            activityIndicatorView.color = UIColor.orange
        }
        
        func saveImage(){
            
            //hokusai is the menu with options to save the image
            let hokusai = Hokusai()
            hokusai.colors = HOKColors(
                backGroundColor: Constantes.COLOR_NARANJA_NAVBAR, //always orange
                buttonColor: UIColor.white,
                cancelButtonColor: UIColor(hexString: "FFA844")!, //light orange
                fontColor: UIColor.black
            )
            hokusai.fontName = "Helvetica"
            hokusai.addButton(save) {
                Drop.down(self.saving, state: DropState.color(Constantes.COLOR_NARANJA_NAVBAR))
                let queue = TaskQueue()
                queue.tasks +=! {
                    UIImageWriteToSavedPhotosAlbum(self.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
                }
                queue.run()
            }
            hokusai.show()
        }
        
        //image!! compleiton selector for when saving an image
        func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
            if didFinishSavingWithError != nil {
                Drop.down(failed, state: DropState.error)
                return
            }
            Drop.down(success, state: DropState.success)
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
            
            button.sizeToFit()
            button.frame.origin = CGPoint(x: 10, y: 10)
            
            saveButton.sizeToFit()
            saveButton.frame.origin = CGPoint(x: frame.size.width-saveButton.frame.width-10, y:10)
            
            if imageview.image != nil{
                activityIndicatorView.stopAnimating()
                let orientation = UIDevice.current.orientation
                
                if orientation == .portrait || orientation == .faceUp || orientation == .faceDown{
                    
                    button.isHidden = false
                    saveButton.isHidden = false
                    
                    let frh = frame.height
                    
                    let fw = frame.width
                    let fh = frh - (button.frame.height + 5) * 2
                    
                    let iw = imageview.image!.size.width
                    let ih = imageview.image!.size.width
                    
                    if(iw < fw && ih < fh){
                        imageview.frame = CGRect(x: fw/2 - iw/2, y: frh/2 - ih/2, width: iw, height: ih)
                    }
                    else{
                        let dw = iw - fw
                        let dh = ih - fh
                        
                        if dw < dh{
                            
                            let nih = fh
                            let niw = fh * iw / ih
                            
                            imageview.frame = CGRect(x: fw/2 - niw/2, y: frh/2 - nih/2, width: niw, height: nih)
                            
                        }
                        else{
                            
                            let niw = fw
                            let nih = fw * ih / iw
                            
                            imageview.frame = CGRect(x: fw/2 - niw/2, y: frh/2 - nih/2, width: niw, height: nih)
                        }
                    }
                }
                else{
                    button.isHidden = true
                    saveButton.isHidden = true
                    imageview.contentMode = .scaleAspectFit
                    imageview.frame = CGRect(origin: CGPoint.zero, size: frame.size)
                }
                
            }
            else{
                activityIndicatorView.startAnimating()
                activityIndicatorView.frame = CGRect(x: frame.size.width/2 - 100, y: frame.size.height/2 - 100, width: 200, height: 200)
            }
        
        }
        
        func renderForDismiss(){
            let view = UIScreen.main.snapshotView(afterScreenUpdates: false)
            view.frame = self.frame
            addSubview(view)
            imageview.isHidden = true
            bgImage.isHidden = true
            blur.isHidden = true
        }

    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        fullImageView?.renderForDismiss()
        super.dismiss(animated: flag, completion: completion)
    }
    
}
