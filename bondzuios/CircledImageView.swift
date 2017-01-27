//
//  CircledImageView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 26/10/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class CircledImageView: UIImageView {
    
    func setBorderOfColor(_ color : UIColor, width : CGFloat){
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        Imagenes.redondeaVista(self, radio: self.frame.width / 2)
    }
}
