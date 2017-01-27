//
//  Animacion.swift
//  bondzuios
//
//  Created by Luis Mariano Arobes on 10/08/15.
//  Copyright (c) 2015 Bondzu. All rights reserved.
// Archivo Localizado

import Foundation
import UIKit

class Animacion
{
    static func shakeAnimation(_ view: UIView)
    {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 10, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 10, y: view.center.y))
        DispatchQueue.main.async(execute: { () -> Void in
            view.layer.add(animation, forKey: "position")
        })
    }
}
