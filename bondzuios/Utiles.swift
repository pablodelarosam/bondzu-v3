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
    var window: UIWindow? = UIApplication.shared.keyWindow
    window = UIApplication.shared.windows[0]
    UIGraphicsBeginImageContextWithOptions(window!.frame.size, window!.isOpaque, 0.0)
    window!.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!;
}

func captureScreenOfView(_ view : UIView) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, view.isOpaque, 0.0)
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!;
}

func imageWithImage(_ image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}




func getImageInBackground(url string : String, block : @escaping ((UIImage)->Void)){
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.high).async(execute: {
        
        let urlG = URL(string: string)
        
        guard let url = urlG else{
            return
        }
        
        let data = try? Data(contentsOf: url)
        
        guard data != nil else{
            print("error getting image \(url)");
            DispatchQueue.main.async{
                block(UIImage())
            }
            return
        }
        
        DispatchQueue.main.async{
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
func getImageInBackground(url string : String, block : @escaping ((UIImage?, Bool)->Void)){
    Constantes.get_bondzu_queue().async(execute: {
        
        let urlG = URL(string: string)
        
        guard let url = urlG else{
            DispatchQueue.main.async{
                print("Could not form URL in Utiles.getImageInBackground \(string)")
                block(nil,false)
            }
            return
        }
        
        let data = try? Data(contentsOf: url)

        guard data != nil else{
            DispatchQueue.main.async{
                print("error getting image \(string)");
                block(nil,false)
            }
            return
        }

        DispatchQueue.main.async{
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
    static func moveHairLine(_ appearing: Bool, navHairLine: UIImageView?, toolbar: UIToolbar?){
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
            navHairLine!.isHidden = appearing
        }else{
            print("toolbar o hairline son nil")
        }
    }
    
    static func getHairLine(_ navigationBar: UINavigationBar) -> UIImageView?{
        for view in navigationBar.subviews
        {
            for view2 in view.subviews
            {
                if(view2.isKind(of: UIImageView.self) && view2.bounds.size.width == navigationBar.frame.size.width && view2.bounds.size.height < 2)
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
    
    static func urlOfAVPlayer(_ player: AVPlayer?) -> URL?{
        if player != nil {
            if let playerAsset = player!.currentItem?.asset as AVAsset?
            {
                if let urlAsset = playerAsset as? AVURLAsset
                {
                    return urlAsset.url;
                }
            }
        }
        
        return nil;
    }
}
