//
//  CircledImageView.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 26/10/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class CircledImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        Imagenes.redondeaVista(self, radio: self.frame.width / 2)
    }
}
