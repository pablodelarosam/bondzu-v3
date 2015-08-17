//
//  Imagenes.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 13/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import Foundation
import UIKit

class Imagenes
{
    static func resizeImage(#image: UIImage, width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage
    {
        let sizeChange = CGSizeMake(width, height);
        let hasAlpha = true
        let scale: CGFloat = scale // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    static func imageResize (#image:UIImage, sizeChange:CGSize, scale: CGFloat)-> UIImage{
        let hasAlpha = true
        let scale: CGFloat = scale // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    static func redondeaVista(vista: UIView, radio: CGFloat)
    {
        vista.layer.cornerRadius = radio
        vista.layer.masksToBounds = true
    }
}