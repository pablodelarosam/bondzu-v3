//
//  Utiles.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import UIKit

class Utiles
{
    //Esconder hairline (separacion entre nav bar y toolbar)
    static func moveHairLine(appearing: Bool, navHairLine: UIImageView?, toolbar: UIToolbar?)
    {
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
    
    static func getHairLine(navigationBar: UINavigationBar) -> UIImageView?
    {
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
    
    static func urlOfAVPlayer(player: AVPlayer?) -> NSURL?
    {
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