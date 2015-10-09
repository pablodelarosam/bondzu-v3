//
//  Usuario.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 8/27/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

class Usuario: NSObject {
    
    var name : String
    var photo : String
    var image : UIImage?
    
    var imageLoaderObserver : ((Usuario)->(Void))?

    init(name : String , photo : String){
        self.name = name
        self.photo = photo
        super.init()
        getImageInBackground(url: photo, block: imageReady)
    }
    
    init(name : String , photoFile : PFFile){
        self.name = name
        self.photo = ""
        super.init()
        photoFile.getDataInBackgroundWithBlock {
            (imgData, error) -> Void in
            if error != nil{
                print("error obtiendo imagen: \(error)")
                return
            }
            dispatch_async(dispatch_get_main_queue()){
                self.imageReady(UIImage(data: imgData!)!)
            }
        }
    }

    
    func imageReady(image : UIImage){
        self.image = image
        if let delegate = imageLoaderObserver{
            delegate(self)
            imageLoaderObserver = nil
        }
    }
    
}
