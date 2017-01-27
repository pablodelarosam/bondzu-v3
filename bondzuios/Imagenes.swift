//
//  Imagenes.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 13/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//  Archivo localizado

import Foundation
import UIKit

class Imagenes
{
    static func resizeImage(_ image: UIImage, width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage
    {
        let sizeChange = CGSize(width: width, height: height);
        let hasAlpha = true
        let scale: CGFloat = scale // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
    static func imageResize (_ image: UIImage, sizeChange:CGSize, scale: CGFloat)-> UIImage{
        let hasAlpha = true
        let scale: CGFloat = scale // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
    
    static func redondeaVista(_ vista: UIView, radio: CGFloat)
    {
        vista.layer.cornerRadius = radio
        vista.layer.masksToBounds = true
    }
}
