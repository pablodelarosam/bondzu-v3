//
//  Usuario.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 8/27/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit

class Usuario: NSObject {
    
    var name : String
    var photo : String
    var image : UIImage?
    
    var imageLoaderObserver : ((Usuario)->(Void))?

    init(name : String , photo : String){
        self.name = name
        self.photo = photo
    }
    
    func loadImage(){
        getImageInBackground(url: photo, block: imageReady)
    }
    
    func imageReady(image : UIImage){
        self.image = image
        if let delegate = imageLoaderObserver{
            delegate(self)
        }
    }
    
}
