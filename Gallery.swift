//
//  Gallery.swift
//  bondzuios
//
//  Created by Ricardo Lopez Focil on 12/7/15.
//  Copyright © 2015 Bondzu. All rights reserved.
//

import UIKit
import Parse

protocol GalleryLoadingProtocol{
    func galleryImageDidFinishLoading(_ gallery : Gallery)
    func galleryImageDidFailLoading(_ gallery : Gallery)
}

class Gallery{
    
    let animalID : String
    let imageFile : PFFile
    var image : UIImage?
    
    /**
     - parameter object: The PFObject to parse.
     - parameter delegate: The delegate to notify when the image is ready.
     - parameter loadImage: This parameter will be only taken in mind if the delegate is nil. It tells the wether the associated image is loaded or notociated image. The default value is false
     
     */
    init(object : PFObject, delegate : GalleryLoadingProtocol?, loadImage : Bool = false ){
        let animalObject = object["animal_id"] as! PFObject
        self.animalID =  animalObject.objectId!
        self.imageFile = object[TableGalleryColumnNames.Image.rawValue] as! PFFile
        
        //Determine if the image should be loaded or not
        if delegate != nil || loadImage{
            // Best practice to manage GCD
            // Regular priority
            DispatchQueue.global(qos: .userInitiated).async { () -> Void in
                
                if let imageData = try? self.imageFile.getData(), let img = UIImage(data: imageData) {
                    // all set and done run completition closure
                    DispatchQueue.main.async(execute: {() -> Void in
                        self.image = img
                        delegate?.galleryImageDidFinishLoading(self)
                    })
                
                } else {
                    delegate?.galleryImageDidFailLoading(self)
                }
                
            }
        } // End determine if the image should be downloaded
        else{ //Should not download or image data invalid
            delegate?.galleryImageDidFailLoading(self)
        }
        
    } //End constructor
    
} //End class
