//
//  Animacion.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
//

import Foundation
import UIKit

class Animacion
{
    static func shakeAnimation(view: UIView)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(CGPoint: CGPointMake(view.center.x - 10, view.center.y))
        animation.toValue = NSValue(CGPoint: CGPointMake(view.center.x + 10, view.center.y))
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            view.layer.addAnimation(animation, forKey: "position")
        })
    }
}
