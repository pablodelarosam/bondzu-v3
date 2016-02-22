//
//  Utiles.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import Foundation
import AVKit
import AVFoundation
import UIKit

func captureScreen() -> UIImage {
    var window: UIWindow? = UIApplication.sharedApplication().keyWindow
    window = UIApplication.sharedApplication().windows[0]
    UIGraphicsBeginImageContextWithOptions(window!.frame.size, window!.opaque, 0.0)
    window!.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
}

func captureScreenOfView(view : UIView) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, view.opaque, 0.0)
    view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image;
}

func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}

@available(*, deprecated=1.0, message="Please use the new functions that returns if the image could be created", renamed="getImageInBackground:stringblock:" )
func getImageInBackground(url string : String, block : (UIImage->Void)){
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
        
        let urlG = NSURL(string: string)
        
        guard let url = urlG else{
            return
        }
        
        let data = NSData(contentsOfURL: url)
        
        guard data != nil else{
            print("error getting image \(url)");
            dispatch_async(dispatch_get_main_queue()){
                block(UIImage())
            }
            return
        }
        
        dispatch_async(dispatch_get_main_queue()){
            block(UIImage(data: data!)!)
        }
    })
}

/**
 Gets an image from a URL String anf if the image could be requested.
 ### Important. This methods work in background but calls the block in the main thread. ###
 
 - parameter string: The URL String to parse.
 - parameter block : A block to call when the operation succeded or failed. The block paramaters are described below.
    - UIImage?: The generated image. If the boolean is true the image wont be nil.
    - Bool: The completed flag.
 
 - returns: void.
*/
func getImageInBackground(url string : String, block : ((UIImage?, Bool)->Void)){
    dispatch_async( Constantes.get_bondzu_queue() , {
        
        let urlG = NSURL(string: string)
        
        guard let url = urlG else{
            dispatch_async(dispatch_get_main_queue()){
                print("Could not form URL in Utiles.getImageInBackground \(string)")
                block(nil,false)
            }
            return
        }
        
        let data = NSData(contentsOfURL: url)

        guard data != nil else{
            dispatch_async(dispatch_get_main_queue()){
                print("error getting image \(string)");
                block(nil,false)
            }
            return
        }

        dispatch_async(dispatch_get_main_queue()){
            let image = UIImage(data: data!)
            if let image = image{
                block(image, true)
            }
            else{
                block(nil,false)
                print("Invalid data in Utiles.getImageInBackground  \(string)")
            }
        }
    })
}


func mainThreadWarning(){
    print("You are blocking the main thread!\nTo debug put a symbolic link in mainThreadWarning.\nPrinted from Utiles.mainThreadWarning()")
}

class Utiles{
    //Esconder hairline (separacion entre nav bar y toolbar)
    static func moveHairLine(appearing: Bool, navHairLine: UIImageView?, toolbar: UIToolbar?){
        if (navHairLine != nil && toolbar != nil)
        {
            var hairLineFrame = navHairLine!.frame
            
            if appearing
            {
                hairLineFrame.origin.y += toolbar!.bounds.size.height
            }
            else
            {
                hairLineFrame.origin.y -= toolbar!.bounds.size.height
            }
            
            navHairLine!.frame = hairLineFrame
            navHairLine!.hidden = appearing
        }else{
            print("toolbar o hairline son nil")
        }
    }
    
    static func getHairLine(navigationBar: UINavigationBar) -> UIImageView?{
        for view in navigationBar.subviews
        {
            for view2 in view.subviews
            {
                if(view2.isKindOfClass(UIImageView) && view2.bounds.size.width == navigationBar.frame.size.width && view2.bounds.size.height < 2)
                {
                    if let imageHairLine = view2 as? UIImageView
                    {
                        return imageHairLine
                    }
                }
            }
        }
        return nil
    }
    
    static func urlOfAVPlayer(player: AVPlayer?) -> NSURL?{
        if player != nil {
            if let playerAsset = player!.currentItem?.asset as AVAsset?
            {
                if let urlAsset = playerAsset as? AVURLAsset
                {
                    return urlAsset.URL;
                }
            }
        }
        
        return nil;
    }
}
